import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";

export class S3Adapter {
	private readonly s3Client: S3Client;

	public constructor() {
		this.s3Client = new S3Client({});
	}

	public async getFileBuffer(bucket: string, key: string): Promise<Buffer> {
		const command = new GetObjectCommand({
			Bucket: bucket,
			Key: key,
		});

		const response = await this.s3Client.send(command);
		
		if (!response.Body) {
			throw new Error("S3 body is empty");
		}

		const byteArray = await response.Body.transformToByteArray();
		return Buffer.from(byteArray);
	}
}