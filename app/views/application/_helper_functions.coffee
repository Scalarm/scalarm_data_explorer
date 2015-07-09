window.getWithSession = (url, params, onSuccess, onError) =>
  $.ajax(
    url: url,
    xhrFields:
      withCredentials: true
    success: onSuccess,
    error: (typeof(onError) == "function" && onError) || (jqXHR, textStatus, errorThrown) =>
      console.log("Error on request to #{url}: #{textStatus} #{errorThrown}")
  )
