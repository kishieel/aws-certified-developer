/**
 * @returns {Promise<{ statusCode: number, message: string }>}
 */
exports.handler = async () => {
    console.log('Order has been successfully created.')
    return {statusCode: 201, message: 'Your order has been successfully created.'};
}

