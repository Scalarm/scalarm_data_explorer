

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

  
window.getMoesInfoJson = (input_params, output_params) =>
  moes_info_json_tmp = []
  for i in [0..input_params.length]
    moes_info_json_tmp.push({label: input_params[i], id: input_params[i], type: "input_parameter"})
  moes_info_json_tmp.push({ label: "-----------", id: "nil", type: "" })
  for i in [0..output_params.length]
    moes_info_json_tmp.push({label: output_params[i], id: output_params, type: "output_parameter"})
  moes_info_json_tmp