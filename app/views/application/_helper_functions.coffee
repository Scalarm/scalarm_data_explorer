

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
  for i in [0..input_params.length-1]
    moes_info_json_tmp.push({label: input_params[i], id: input_params[i], type: "input_parameter"})
  moes_info_json_tmp.push({ label: "-----------", id: "nil", type: "" })
  for i in [0..output_params.length-1]
    moes_info_json_tmp.push({label: output_params[i], id: output_params[i], type: "moes_parameter"})
  moes_info_json_tmp


# always return integer as type
window.getMoeInfo = (output_params, values) =>
  moes_info_tmp = {"moes": "", "moes_and_params": "", "params": "", "moes_types": [], "moes_names": [], "inputs_types": "", "inputs_names": ""}
  for i in [0..output_params.length-1]
    moes_info_tmp["moes_names"].push(output_params[i])
    if typeof values[i] == 'string'
      type = 'string'
    else
      if !!(values[i] % 1)
        type = 'float'
      else
        type = 'integer'
    moes_info_tmp["moes_types"].push(type)

  moes_info_tmp


