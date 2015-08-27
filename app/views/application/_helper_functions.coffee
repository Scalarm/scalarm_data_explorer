

window.getWithSession = (url, params, onSuccess, onError) =>
  $.ajax(
    url: url,
    data: params,
    xhrFields:
      withCredentials: true
    success: onSuccess,
    error: onError
  )

window.onErrorHandler = (jqXHR, textStatus, errorThrown) =>
  $(".loading_chart_gif").hide()
  toastr.error("An error has occured: #{escapeHtml(jqXHR.responseText)} #{escapeHtml(errorThrown)}")


window.escapeHtml = (str) =>
  div = document.createElement('div')
  div.appendChild(document.createTextNode(str))
  div.innerHTML
