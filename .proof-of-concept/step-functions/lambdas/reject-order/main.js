/**
 * @returns {Promise<{ statusCode: number, message: string }>}
 */
exports.handler = async () => {
    console.log('Order has been rejected.')
    return {
        statusCode: 422,
        message: 'Your balance is too low to complete this transaction. Please add funds to your account.'
    };
}
