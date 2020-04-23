using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawToTexScript : MonoBehaviour
{
	public Texture2D refTex;
	public int rayCount = 2;
	public float raySegmentLength = 10.0f;

	private Camera cam;
	//private Texture2D origTex;
	private Vector2 screenDim;
	private Vector2 hitTexCoord;
	private Vector3 camTopCorner, camBotCorner;
	private Vector3 rayOrigin;
	private Color defaultCol;
	private float pixelOffset;

	// Start is called before the first frame update
	void Start()
	{
		cam = GameObject.FindObjectOfType<Camera>();

		//origTex = refTex;

		pixelOffset = 0f;

		screenDim = new Vector2(cam.pixelWidth, cam.pixelHeight);
		
		rayOrigin = cam.gameObject.transform.position;

		defaultCol = new Color(0f, 0f, 0f, 0f);
	}

	// Update is called once per frame
	void Update()
	{
		// update ray origin
		rayOrigin = cam.gameObject.transform.position;

		// update camera world bounds
		// get bottom worldspace corner
		//Vector3 screenPt = new Vector3(0f, 0f, 1f);
		//camBotCorner = cam.ScreenToWorldPoint(screenPt);
		////Debug.DrawRay(rayOrigin, (camBotCorner - rayOrigin) * raySegmentLength, Color.cyan);
		//// get top worldspace corner
		//screenPt = new Vector3(screenDim.x, screenDim.y, 1f);
		//camTopCorner = cam.ScreenToWorldPoint(screenPt);
		//Debug.DrawRay(rayOrigin, (camTopCorner - rayOrigin)*raySegmentLength, Color.cyan);


		// cast the rays
		CastAllRays();
	}

	private void CastAllRays()
	{
		for (int i = 0; i < rayCount; i++)
			CastRay(i);
	}

	private void CastRay(int index)
	{
		// Get pixel coordinates
		float screenX, screenY;
		if (index == 0)
		{
			// if the first ray, make it center
			screenX = screenDim.x / 2f;
			screenY = screenDim.y / 2f;
		}
		else
		{
			// else get a random one
			screenX = UnityEngine.Random.Range(0f, screenDim.x);
			screenY = UnityEngine.Random.Range(0f, screenDim.y);
		}

		// make screen coordinate and turn to a world coordinate
		Vector3 screenPt = new Vector3(screenX, screenY, 1f);
		Vector3 aimPoint = cam.ScreenToWorldPoint(screenPt);

		//Debug.Log(aimPoint.ToString("F3"));

		// Get ray dir
		Vector3 rayDir = (aimPoint - rayOrigin).normalized;

		// Cast ray
		Ray cast = new Ray(rayOrigin, rayDir * raySegmentLength);
		RaycastHit hit;
		Physics.Raycast(cast, out hit);

		//Debug.DrawRay(rayOrigin, rayDir * raySegmentLength, Color.green);

		// If hit: bounce
		if (hit.collider)
		{
			hitTexCoord = hit.textureCoord;
			CastBounce(cast, hit);
		}
	}

	private void CastBounce(Ray ray, RaycastHit hit)
	{
		// Get reflectiveness
		Color reflectCol = GetHitRelfectiveness(hit);
		float reflect = reflectCol.r;
		//Debug.Log("Reflective: " + reflect.ToString("F2"));

		Color color;

		Vector3 reflected = Vector3.Reflect(ray.direction, hit.normal);

		//Debug.DrawRay(hit.point, reflected * raySegmentLength * reflect , Color.red);
		if (Physics.Raycast(hit.point, reflected * raySegmentLength * reflect, out hit))
		{
			// Output color found
			color = GetHitColor(hit);
			//Debug.Log(color);

			// get screenspace coordinate
			Vector3 screenCoord = cam.WorldToScreenPoint(hit.point);

			// transform points into cam space to eliminate some 3d considerations
			//Vector3 newHitPt = cam.transform.worldToLocalMatrix * hit.point;
			//
			//Vector3 screenPt = new Vector3(0f, 0f, 1f);
			//camBotCorner = cam.transform.worldToLocalMatrix * cam.ScreenToWorldPoint(screenPt);
			//
			//screenPt = new Vector3(screenDim.x, screenDim.y, 1f);
			//camTopCorner = cam.transform.worldToLocalMatrix * cam.ScreenToWorldPoint(screenPt);

			//Vector2 uv = new Vector2(
			//	(newHitPt.x - camBotCorner.x) / (camTopCorner.x - camBotCorner.x),
			//	(newHitPt.y - camBotCorner.y) / (camTopCorner.y - camBotCorner.y)
			//	);

			if (screenCoord.y - screenDim.y > pixelOffset)
				pixelOffset = screenCoord.y - screenDim.y;

			// set texture pixel color found from hit
			refTex.SetPixel((int)(hitTexCoord.x * refTex.width), (int)(hitTexCoord.y * refTex.height), color);
			//refTex.SetPixel((int)(screenCoord.x / screenDim.x * refTex.width), (int)((1f - (screenCoord.y + pixelOffset) / screenDim.y) * refTex.height), color);
		}
		else
		{
			// hit nothing (skybox?)
			color = defaultCol;
		}
		
		refTex.Apply();
	}

	// Get objects reflectiveness at ray hit point
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

	// Get objects color at ray hit point
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

	//private void OnDestroy()
	//{
	//	refTex = origTex;
	//}
}
