/**
 * @param {Array<{ productId: number, quantity: number }>} event
 * @param {import('aws-lambda').Context} context
 * @returns {Promise<{message: string, statusCode: number}|{totalPrice: number, enoughCoins: boolean, statusCode: number, products: {quantity: *, productId: *, price: number}[]}>}
 */
exports.handler = async (event, context) => {
    console.log(`Processing newly placed order.`)

    const products = event.map((order) => ({
        productId: order.productId,
        quantity: order.quantity,
        price: getProductPrice(order.productId)
    }));

    const totalPrice = products.reduce((acc, product) => acc + product.quantity * product.price, 0);
    const enoughCoins = checkBalance(totalPrice);

    return {statusCode: 200, products, totalPrice, enoughCoins};
}


/**
 * Stub function for fetching product's price
 * @param {number} productId
 * @returns {number}
 */
const getProductPrice = (productId) => {
    return Math.floor(Math.random() * productId);
}

/**
 * Stub function to validate user's balance
 * @param {number} totalPrice
 * @returns {boolean}
 */
const checkBalance = (totalPrice) => {
    return Math.random() > 0.5;
}
