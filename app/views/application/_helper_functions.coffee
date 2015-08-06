

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
  toastr.error =("An error has occured: #{errorThrown}, #{textStatus}")