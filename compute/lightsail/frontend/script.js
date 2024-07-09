window.onload = async () => {
    console.log('Hello, world!')
    const responseHTML = document.getElementById('response')
    const response = await fetch('/api');

    if (response.ok) {
        const data = await response.json()
        responseHTML.innerText = data.message
        responseHTML.classList.add('success')
    } else {
        responseHTML.innerText = 'An error occurred'
        responseHTML.classList.add('error')
    }
}
