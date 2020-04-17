using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

/* *
 * Color picking code from agneng_dev on the Unity Forums
 * https://forum.unity.com/threads/trying-to-get-color-of-a-pixel-on-texture-with-raycasting.608431/#post-4072315
 * */

public class ColorPickerScript : MonoBehaviour
{
	public Image colorSwatch;
	public Text colorCode;
	public float rayLength = 10f;

	// Start is called before the first frame update
	void Start()
	{

	}

	// Update is called once per frame
	void Update()
	{
		FireRay();
	}

	private void FireRay()
	{
		// Ray and hit
		Ray ray = new Ray(transform.position, transform.forward * rayLength);
		RaycastHit hit;

		// Raycast, if hit: get pixel color
		Debug.DrawRay(ray.origin, ray.direction, Color.blue);
		if (Physics.Raycast(ray.origin, ray.direction, out hit))
		{
			// Get renderer and its material
			Renderer renderer = hit.collider.GetComponent<MeshRenderer>();
			Texture2D texture2D = renderer.material.mainTexture as Texture2D;
			
			// get texcoord that was hit
			Vector2 pCoord = hit.textureCoord;
			pCoord.x *= texture2D.width;
			pCoord.y *= texture2D.height;
			//Debug.Log(pCoord.ToString("F3"));

			// compensate for tiling and get the texture color
			Vector2 tiling = renderer.material.mainTextureScale;
			Color color = texture2D.GetPixel(Mathf.FloorToInt(pCoord.x * tiling.x), Mathf.FloorToInt(pCoord.y * tiling.y));

			// Output to display
			colorSwatch.color = color;
			colorCode.text = color.ToString("F2");

			//Debug.Log(color);
		}
	}
}