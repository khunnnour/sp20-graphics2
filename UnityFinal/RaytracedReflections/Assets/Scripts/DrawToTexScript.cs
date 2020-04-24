using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawToTexScript : MonoBehaviour
{
	public Cubemap skybox;
	public Texture2D refTex;
	public bool randomRays;
	public float raySegmentLength = 10.0f;
	[Header("Random Ray Settings")]
	public int rayCount = 25;
	[Header("Sweep Ray Settings")]
	public int raysPerFrame = 50;

	private Camera cam;
	//private Texture2D origTex;
	private Vector2 screenDim;
	private Vector2 hitTexCoord;
	private Vector3 camTopCorner, camBotCorner;
	private Vector3 rayOrigin;
	private Color defaultCol;
	private float pixelOffsetX, pixelOffsetY;
	private int totRays, rayIndex, lastIndex;

	// Start is called before the first frame update
	void Start()
	{
		cam = GameObject.FindObjectOfType<Camera>();

		//origTex = refTex;

		pixelOffsetX = 0f;
		pixelOffsetY = 0f;

		screenDim = new Vector2(cam.pixelWidth, cam.pixelHeight);

		rayOrigin = cam.gameObject.transform.position;

		defaultCol = new Color(1f, 1f, 1f, 0f);

		totRays = refTex.width * refTex.height;
		rayIndex = 0;
		lastIndex = 0;
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
		if (randomRays)
		{
			for (int i = 0; i < rayCount; i++)
				CastRngRay(i);
		}
		else
		{
			int loopEnd = lastIndex + raysPerFrame;
			if (loopEnd > totRays) loopEnd = totRays;

			for (rayIndex = lastIndex; rayIndex < loopEnd; rayIndex++)
				CastRay(rayIndex);

			if (loopEnd == totRays)
			{
				lastIndex = 0;
				//pixelOffset += 0.5f;
				//if (pixelOffset > 2f) pixelOffset = -2f;
			}
			else lastIndex = loopEnd;
		}
	}

	// Cast ray based on set rays
	private void CastRay(int index)
	{
		// Get point from index
		Vector2 point = indexToPoint(index);
		// Turn into a uv
		point.x *= 1f / refTex.width;
		point.y *= 1f / refTex.height;

		// Get random offset
		pixelOffsetX = Random.Range(-2f, 2f);
		pixelOffsetY = Random.Range(-2f, 2f);

		// make screen coordinate out of uv
		Vector3 screenPt = new Vector3(point.x * screenDim.x + pixelOffsetX, point.y * screenDim.y + pixelOffsetY, 1f);
		// turn screen point into a world point
		Vector3 aimPoint = cam.ScreenToWorldPoint(screenPt);

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
			// Get reflectiveness
			Color reflectCol = GetHitRelfectiveness(hit);
			float reflect = reflectCol.r;
			//Debug.Log("Reflective: " + reflect.ToString("F2"));

			if (reflect > 0f)
			{
				hitTexCoord = hit.textureCoord;
				CastBounce(cast, hit, reflect);
			}
		}
	}

	// Cast random ray
	private void CastRngRay(int index)
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
			// Get reflectiveness
			Color reflectCol = GetHitRelfectiveness(hit);
			float reflect = reflectCol.r;
			//Debug.Log("Reflective: " + reflect.ToString("F2"));

			if (reflect > 0f)
			{
				hitTexCoord = hit.textureCoord;
				CastBounce(cast, hit, reflect);
			}
		}
	}

	private void CastBounce(Ray ray, RaycastHit hit, float reflect)
	{
		Color color;

		Vector3 reflected = Vector3.Reflect(ray.direction, hit.normal);

		//Debug.DrawRay(hit.point, reflected * raySegmentLength * reflect , Color.red);
		if (Physics.Raycast(hit.point, reflected * raySegmentLength * reflect, out hit))
		{
			// Output color found
			color = GetHitColor(hit);
			//Debug.Log(color);

			// get screenspace coordinate
			//Vector3 screenCoord = cam.WorldToScreenPoint(hit.point);
			//
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

			//if (screenCoord.y - screenDim.y > pixelOffset)
			//	pixelOffset = screenCoord.y - screenDim.y;

			// set texture pixel color found from hit
			//refTex.SetPixel((int)(hitTexCoord.x * refTex.width), (int)(hitTexCoord.y * refTex.height), color);
			//refTex.SetPixel((int)(screenCoord.x / screenDim.x * refTex.width), (int)((1f - (screenCoord.y + pixelOffset) / screenDim.y) * refTex.height), color);
		}
		else
		{
			// hit nothing (skybox?)
			//color = defaultCol;
			color = SampleSkyBox(reflected.normalized);
		}

		refTex.SetPixel((int)(hitTexCoord.x * refTex.width), (int)(hitTexCoord.y * refTex.height), color);
		refTex.Apply();
	}

	// Get objects reflectiveness at ray hit point
	private Color GetHitRelfectiveness(RaycastHit hit)
	{
		// Get renderer and its material
		Renderer renderer = hit.collider.GetComponent<MeshRenderer>();
		Texture2D specularMap = renderer.material.GetTexture("_MetallicGlossMap") as Texture2D;

		// get texcoord that was hit
		Vector2 pCoord = hit.textureCoord;
		pCoord.x *= specularMap.width;
		pCoord.y *= specularMap.height;
		//Debug.Log(pCoord.ToString("F3"));

		// compensate for tiling and get the texture color
		Vector2 tiling = renderer.material.mainTextureScale;
		Color color = specularMap.GetPixel(Mathf.FloorToInt(pCoord.x * tiling.x), Mathf.FloorToInt(pCoord.y * tiling.y));

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

	private Color SampleSkyBox(Vector3 v)
	{
		// Get face index / uv 
		Vector3 vAbs = new Vector3(Mathf.Abs(v.x), Mathf.Abs(v.y), Mathf.Abs(v.z));
		float ma;
		int faceIndex;
		Vector2 uv;

		// if pointing in z-dirs
		if (vAbs.z >= vAbs.x && vAbs.z >= vAbs.y)
		{
			faceIndex = v.z < 0.0f ? 5 : 4;
			ma = 0.5f / vAbs.z;
			uv = new Vector2(v.z < 0.0f ? -v.x : v.x, -v.y);
		}
		// now see if looking in y-dir
		else if (vAbs.y >= vAbs.x)
		{
			faceIndex = v.y < 0.0f ? 3 : 2;
			ma = 0.5f / vAbs.y;
			uv = new Vector2(v.x, v.y < 0.0f ? -v.z : v.z);
		}
		// must be looking in x-dir
		else
		{
			// if act vec3 is -x, then pointing in -x direction
			faceIndex = v.x < 0.0f ? 1 : 0;
			ma = 0.5f / vAbs.x;
			uv = new Vector2(v.x < 0.0f ? v.z : -v.z, -v.y);
		}
		uv *= ma;
		uv += new Vector2(0.5f, 0.5f);

		// Get cubemap face from faceIndex
		CubemapFace face;
		switch (faceIndex)
		{
			case 0:
				face = CubemapFace.NegativeX;
				break;
			case 1:
				face = CubemapFace.PositiveX;
				break;
			case 2:
				face = CubemapFace.PositiveY;
				break;
			case 3:
				face = CubemapFace.NegativeY;
				break;
			case 4:
				face = CubemapFace.NegativeZ;
				break;
			case 5:
				face = CubemapFace.PositiveZ;
				break;
			default:
				face = CubemapFace.PositiveY;
				break;
		}

		return skybox.GetPixel(face, (int)(uv.x * skybox.width * 0.25f), (int)(uv.y * skybox.width * 0.25f));
	}

	Vector2 indexToPoint(int index)
	{
		int acc = index, y = 0;
		while (acc > refTex.width)
		{
			acc -= refTex.width;
			y++;
		}

		return new Vector2(acc, y);
	}
	int pointToIndex(Vector2 point)
	{
		return (int)(point.x) + (int)(point.y) * refTex.width;
	}


	//private void OnDestroy()
	//{
	//	refTex = origTex;
	//}
}
