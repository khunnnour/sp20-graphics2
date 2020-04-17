using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveScript : MonoBehaviour
{
	public float speed = 10f;

	private float xMove,yMove,zMove;

    // Start is called before the first frame update
    void Start()
    {
		xMove = 0f;
		yMove = 0f;
	}

    // Update is called once per frame
    void Update()
    {
		GetInput();
		Move();
    }

	private void GetInput()
	{
		xMove = Input.GetAxis("Horizontal");
		yMove = Input.GetAxis("Vertical");

		if (Input.GetKey(KeyCode.Q))
			zMove = -1f;
		else if (Input.GetKey(KeyCode.E))
			zMove = 1f;
		else
			zMove = 0f;
	}

	private void Move()
	{
		Vector3 newPos = gameObject.transform.position;

		newPos  += (transform.forward * yMove 
				+	transform.right * xMove
				+	transform.up * zMove) * speed * Time.deltaTime;

		gameObject.transform.position = newPos;
	}
}
