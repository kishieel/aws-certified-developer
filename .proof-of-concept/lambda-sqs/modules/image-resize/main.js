const {S3Client, CopyObjectCommand} = require('@aws-sdk/client-s3');
const s3Client = new S3Client();

exports.handler = async (event) => {
    // @info: this is only mock function, there is no actual resizing here

    try {
        await Promise.all(event.Records.map(async ({ body }) => {
            const { size, s3 } = JSON.parse(body);
            const prefix = size.join('x')
            const filename = s3.object.key.split('/').slice(-1)[0];
            return s3Client.send(new CopyObjectCommand({
                Bucket: s3.bucket.name,
                CopySource: `${s3.bucket.name}/${s3.object.key}`,
                Key: `thumbnails/${prefix}/${filename}`
            }))
        }))

        return {
            statusCode: 200,
            body: JSON.stringify({message: 'Image resized successfully.'})
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({message: 'An error occurred while resizing the image.'})
        };
    }
};
