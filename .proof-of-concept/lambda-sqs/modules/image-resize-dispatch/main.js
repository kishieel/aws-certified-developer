const {SQSClient, SendMessageCommand} = require('@aws-sdk/client-sqs');
const sqsClient = new SQSClient();

exports.handler = async (event) => {
    try {
        const thumbnailSizes = JSON.parse(process.env.THUMBNAIL_SIZES);

        await Promise.all(event.Records.flatMap(({s3}) => {
            return thumbnailSizes.map((size) => {
                const t = size.split('x');
                return sqsClient.send(new SendMessageCommand({
                    QueueUrl: process.env.QUEUE_URL,
                    MessageBody: JSON.stringify({
                        size: [parseInt(t[0]), parseInt(t[0])],
                        s3: s3
                    })
                }))
            })
        }))

        return {
            statusCode: 200,
            body: JSON.stringify({message: 'Image resize requests dispatched successfully.'})
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({message: 'An error occurred while dispatching the image resize requests.'})
        };
    }
};
