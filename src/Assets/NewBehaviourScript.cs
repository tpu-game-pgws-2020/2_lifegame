using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
   [SerializeField]
    CustomRenderTexture texture;
    
    [SerializeField]
    [Range(0.1f , 100.0f)] public float sample_float;

    // Start is called before the first frame update
    void Start()
    {
        texture.Initialize();
    }

    // Update is called once per frame
    void Update()
    {
        Application.targetFrameRate = (int)sample_float;
    }
}
