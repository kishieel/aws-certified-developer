exports.handler = (event) => {
    console.log('EVENT: ', JSON.stringify(event));
    return {statusCode: 200};
}
