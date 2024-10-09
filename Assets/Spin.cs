using UnityEngine;

public class Spin : MonoBehaviour
{
	[SerializeField] float m_speed = 1;

	private void Update()
	{
		transform.Rotate(0, 0, Time.deltaTime * m_speed);
	}
}
