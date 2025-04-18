export function getTampermonkey() {
  return window.external?.Tampermonkey
}

export function getViolentmonkey() {
  return window.external?.Violentmonkey
}

export function getFiremonkey() {
  return window.external?.FireMonkey
}


export function canInstallUserJS() {
  return getTampermonkey() || getViolentmonkey() || getFiremonkey()
}

export async function canInstallUserCSS() {
  if (getFiremonkey()) {
    return true
  }

  if (localStorage.getItem('stylusDetected') === '1') {
    return true
  }
  postMessage({ type: 'style-version-query', name: "whatever", namespace: "whatever", url: location.href }, location.origin);
  return new Promise(resolve => setTimeout(function() {
    resolve(localStorage.getItem('stylusDetected') === '1')
  }, 200))
}

window.addEventListener("message", function(event) {
  if (event.origin !== location.origin)
    return;

  if (event.data.type !== "style-version")
    return;

  localStorage.setItem('stylusDetected', '1')
})
