using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Unity.Collections;
using Unity.Jobs;
using System.IO;
using System.Numerics;
using Unity.Collections.LowLevel.Unsafe;
using Vector3 = UnityEngine.Vector3;
using Vector4 = UnityEngine.Vector4;
using Matrix4x4 = UnityEngine.Matrix4x4;

//喵刀老师我滴神！！！https://zhuanlan.zhihu.com/p/107664564
public class ModelSmoothNormalImporter : AssetPostprocessor
{
    public struct CollectNormalJob : IJobParallelFor
    {
        [ReadOnly] public NativeArray<Vector3> normals, vertex;

        [NativeDisableContainerSafetyRestriction]
        public NativeArray<UnsafeHashMap<Vector3, Vector3>.ParallelWriter> result;

        public CollectNormalJob(NativeArray<Vector3> normals, NativeArray<Vector3> vertex,
            NativeArray<UnsafeHashMap<Vector3, Vector3>.ParallelWriter> result)
        {
            this.normals = normals;
            this.vertex = vertex;
            this.result = result;
        }

        void IJobParallelFor.Execute(int index)
        {
            for (int i = 0; i < result.Length + 1; i++)
            {
                if (i == result.Length)
                {
                    Debug.LogError($"重合顶点数量({i})超出限制！");
                    break;
                }
                
                // Debug.Log("导入" + result[i]);

                if (result[i].TryAdd(vertex[index], normals[index]))
                {
                    break;
                }
            }
        }
    }
    
    public struct BakeNormalJob : IJobParallelFor
    {
        [ReadOnly] public NativeArray<Vector3> vertex, normals;
        [ReadOnly] public NativeArray<Vector4> tangents;

        [NativeDisableContainerSafetyRestriction] 
        [ReadOnly] public NativeArray<UnsafeHashMap<Vector3, Vector3>> result;
        [ReadOnly] public bool existColors;
        public NativeArray<Color> colors;

        public BakeNormalJob(NativeArray<Vector3> vertex, NativeArray<Vector3> normals, NativeArray<Vector4> tangents,
            NativeArray<UnsafeHashMap<Vector3, Vector3>> result, bool existColors, NativeArray<Color> colors)
        {
            this.vertex = vertex;
            this.normals = normals;
            this.tangents = tangents;
            this.result = result;
            this.existColors = existColors;
            this.colors = colors;
        }

        void IJobParallelFor.Execute(int index)
        {
            Vector3 smoothedNormals = Vector3.zero;
            for (int i = 0; i < result.Length; i++)
            {
                if (result[i][vertex[index]] != Vector3.zero)
                {
                    smoothedNormals += result[i][vertex[index]];
                }
                else
                {
                    break;
                }
            }
            smoothedNormals = smoothedNormals.normalized;

            //将法线转换到切线空间中
            var bitangent = (Vector3.Cross(normals[index], tangents[index]) * tangents[index].w).normalized;
            var tbn = new Matrix4x4(tangents[index], bitangent, normals[index], Vector4.zero);
            tbn = tbn.transpose;
            var bakedNormal = tbn.MultiplyVector(smoothedNormals).normalized;
            //将法线存入顶点色rg通道
            Color color = new Color();
            color.r = bakedNormal.x * 0.5f + 0.5f;
            color.g = bakedNormal.y * 0.5f + 0.5f;
            color.b = existColors ? colors[index].b : 1;
            color.a = existColors ? colors[index].a : 1;
            colors[index] = color;
        }
    }
    
    //模型导入前
    private void OnPreprocessModel()
    {
        if (assetPath.Contains("@@@")) 
            // AssetPostprocessor.assetPath: The path name of the asset being imported，指导入的资产的路径名，只对新复制的模型更改平滑法线导入方式
        {
            ModelImporter model = assetImporter as ModelImporter;//创建ModelImporter的一个对象
            model.importNormals = ModelImporterNormals.Calculate;//模型导入法线的计算方式设计为由Unity自己计算
            model.normalCalculationMode = ModelImporterNormalCalculationMode.AngleWeighted;//考虑每个角的角度权重来计算法线
            model.normalSmoothingAngle = 180.0f;//平滑法线使用的角度，设置为180意味着所有角度的法线都会被平滑
            model.importAnimation = false;//不会导入动画
            model.materialImportMode = ModelImporterMaterialImportMode.None;//不会导入材质
        }
    }
    
    //模型导入后
    private void OnPostprocessModel(GameObject g)
    {
        if (!g.name.Contains("_ol") || g.name.Contains("@@@"))
        {
            return;
        }
        
        ModelImporter model = assetImporter as ModelImporter;

        string src = model.assetPath;
        string dst = Path.GetDirectoryName(src) + "/@@@" + Path.GetFileName(src);//创建一个新的路径

        if (!File.Exists(Application.dataPath + "/" + dst.Substring(7)))
            //在Assets文件夹下寻找dst是否存在，如果不存在就基于src复制一个模型
            //Application.dataPath返回的是绝对路径
            //而dst或得到的是相对于Assets文件夹的路径，dst.Substring(7)得到的是dst去除开头"/Assets"后的文件路径
        {
            AssetDatabase.CopyAsset(src, dst);
            AssetDatabase.ImportAsset(dst);
        }
        else
        {
            var go = AssetDatabase.LoadAssetAtPath<GameObject>(dst);

            Dictionary<string, Mesh> originalMesh = GetMesh(g), smoothedMesh = GetMesh(go);

            foreach (var item in originalMesh)
            {
                Mesh m = item.Value;
                m.colors = ComputeSmoothedNormalByJob(smoothedMesh[item.Key], m);
            }
            Debug.Log("Computed Finished!");
            AssetDatabase.DeleteAsset(dst);
        }
    }
    
    //获取模型的所有网格体，并将其存在一个Dictionary中
    Dictionary<string, Mesh> GetMesh(GameObject go)
    {
        Dictionary<string, Mesh> dic = new Dictionary<string, Mesh>();
        foreach (var item in go.GetComponentsInChildren<MeshFilter>())
        {
            dic.Add(item.name, item.sharedMesh);
        }

        if (dic.Count == 0)
        {
            foreach (var item in go.GetComponentsInChildren<SkinnedMeshRenderer>())
            {
                dic.Add(item.name, item.sharedMesh);
            }
        }

        return dic;
    }

    Color[] ComputeSmoothedNormalByJob(Mesh smoothedMesh, Mesh originalMesh, int maxOverlapvertices = 10)
    {
        int sourceVertexCount = smoothedMesh.vertexCount, originalMeshVertexCount = originalMesh.vertexCount;
        //CollectNormalJob Data
        NativeArray<Vector3> normals = new NativeArray<Vector3>(smoothedMesh.normals, Allocator.Persistent), // 基于数据构造NativeArray
            vertex = new NativeArray<Vector3>(smoothedMesh.vertices, Allocator.Persistent), // 基于数据构造NativeArray
            smoothedNormals = new NativeArray<Vector3>(sourceVertexCount, Allocator.Persistent); // 基于长度构造NativeArray
        var result = new NativeArray<UnsafeHashMap<Vector3, Vector3>>(maxOverlapvertices, Allocator.Persistent);
        var resultParallel =
            new NativeArray<UnsafeHashMap<Vector3, Vector3>.ParallelWriter>(result.Length * 10, Allocator.Persistent);
        //NormalBakeJob Data
        NativeArray<Vector3> normalsO = new NativeArray<Vector3>(originalMesh.normals, Allocator.Persistent),
            vertexO = new NativeArray<Vector3>(originalMesh.vertices, Allocator.Persistent);
        var tangents = new NativeArray<Vector4>(originalMesh.tangents, Allocator.Persistent);
        var colors = new NativeArray<Color>(originalMeshVertexCount, Allocator.Persistent);

        for (int i = 0; i < result.Length; i++)
        {
            result[i] = new UnsafeHashMap<Vector3, Vector3>(sourceVertexCount * 10, Allocator.Persistent);
            resultParallel[i] = result[i].AsParallelWriter();
        }

        bool existColors = originalMesh.colors.Length == originalMeshVertexCount;
        if (existColors)
        {
            colors.CopyFrom(originalMesh.colors);
        }

        CollectNormalJob collectNormalJob = new CollectNormalJob(normals, vertex, resultParallel);
        BakeNormalJob bakeNormalJob = new BakeNormalJob(vertexO, normalsO, tangents, result, existColors, colors);
        
        bakeNormalJob.Schedule(originalMeshVertexCount, 100, collectNormalJob.Schedule(sourceVertexCount, 100)).Complete();

        //复制结果
        Color[] resultColors = new Color[colors.Length];
        colors.CopyTo(resultColors);

        //释放内存
        normals.Dispose();
        vertex.Dispose();
        result.Dispose();
        smoothedNormals.Dispose();
        resultParallel.Dispose();
        normalsO.Dispose();
        vertexO.Dispose();
        tangents.Dispose();
        colors.Dispose();

        return resultColors;
    }
}
