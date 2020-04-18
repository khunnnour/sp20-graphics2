using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayBounceColorPickTestScript : MonoBehaviour
{
	public float raySegmentLength = 10.0f;

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
		Ray ray = new Ray(transform.position, transform.forward);
		RaycastHit hit;

		// Raycast, if hit: Cast bounce
		Debug.DrawRay(ray.origin, ray.direction * raySegmentLength, Color.blue);
		if (Physics.Raycast(ray.origin, ray.direction * raySegmentLength, out hit))
		{
			CastBounce(ray, hit);
		}
	}

	private void CastBounce(Ray ray, RaycastHit hit)
	{
		// Get reflectiveness
		Color reflectCol=GetHitRelfectiveness(hit);
		float reflect = reflectCol.r;
		Debug.Log("Reflective: "+reflect.ToString("F2"));

		Vector3 reflected = Vector3.Reflect(ray.direction, hit.normal);

		Debug.DrawRay(hit.point, reflected * raySegmentLength* reflect, Color.red);
		if (Physics.Raycast(hit.point, reflected * raySegmentLength* reflect, out hit))
		{
			// Output color found
			//Debug.Log(GetHitColor(hit));
		}
	}

	private Color GetHitColor(RaycastHit hit)
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

		// Return color found
		return color;
	}

	private Color GetHitRelfectiveness(RaycastHit hit)
	{
		// Get renderer and its material
		Renderer renderer = hit.collider.GetComponent<MeshRenderer>();
		Texture2D texture2D = renderer.material.GetTexture("_MetallicGlossMap") as Texture2D;

		// get texcoord that was hit
		Vector2 pCoord = hit.textureCoord;
		pCoord.x *= texture2D.width;
		pCoord.y *= texture2D.height;
		//Debug.Log(pCoord.ToString("F3"));

		// compensate for tiling and get the texture color
		Vector2 tiling = renderer.material.mainTextureScale;
		Color color = texture2D.GetPixel(Mathf.FloorToInt(pCoord.x * tiling.x), Mathf.FloorToInt(pCoord.y * tiling.y));

		// Return color found
		return color;
	}
}
