const {S3Client, PutObjectCommand} = require('@aws-sdk/client-s3');
const s3Client = new S3Client();

exports.handler = async (event) => {
    try {
        const buffer = Buffer.from(event.body, 'base64');
        await s3Client.send(new PutObjectCommand({
            Bucket: process.env.BUCKET_NAME,
            Key: `images/${Array.from(Array(20), () => Math.floor(Math.random() * 36).toString(36)).join('')}.png`,
            Body: buffer,
            ContentType: 'image/png',
        }))
        return {
            statusCode: 200,
            body: JSON.stringify({message: 'Image uploaded successfully.'})
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({message: 'An error occurred while uploading the image.'})
        };
    }
};
