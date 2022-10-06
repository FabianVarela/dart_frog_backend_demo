const app = document.getElementById('root')

const logo = document.createElement('img')
logo.src = 'http://localhost:8080/images/logo_original.png'

logo.setAttribute('width', '300')
logo.setAttribute('height', '300')

const container = document.createElement('div')
container.setAttribute('class', 'container')

app.appendChild(logo)
app.appendChild(container)

var request = new XMLHttpRequest()
request.open('GET', 'http://localhost:8080/json', true)

request.onload = function () {
  var data = JSON.parse(this.response)
  console.log(data)

  if (request.status >= 200 && request.status < 400) {
    data.forEach(user => {
      const card = document.createElement('div')
      card.setAttribute('class', 'card')

      const h3 = document.createElement('h3')
      h3.textContent = `${user.name} · ${user.age}`

      const p1 = document.createElement('p')
      p1.textContent = `Message: ${user.serverMessage}`

      const p2 = document.createElement('p')
      p2.textContent = `Dirección: ${user.address.number} - ${user.address.street}`

      container.appendChild(card)

      card.appendChild(h3)
      card.appendChild(p1)
      card.appendChild(p2)
    })
  } else {
    const errorMessage = document.createElement('marquee')
    errorMessage.textContent = `Gah, it's not working!`

    app.appendChild(errorMessage)
  }
}

// Send request
request.send()
