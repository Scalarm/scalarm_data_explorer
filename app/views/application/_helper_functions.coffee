

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
  if jqXHR.responseText is ""
    toastr.error("Unknown error occured")
  else
    toastr.error("An error has occured: #{escapeHtml(jqXHR.responseText)}")


window.escapeHtml = (str) =>
  div = document.createElement('div')
  div.appendChild(document.createTextNode(str))
  div.innerHTML


window.reload_checkbox = ->
  new_checkbox = ''
  for iter of moes_info_json
    param = moes_info_json[iter]
    if param.type == 'moes_parameter'
      new_checkbox = new_checkbox + '<span class=\'small-2 columns end\'><label><input id=\'' + escapeHtml(param.id) + '\' style=\'margin-right:5px;\' type=\'checkbox\'>' + escapeHtml(param.label) + '</label></span> '

  ### append new values###
  $(' .moes_infos').each ->
    $(this).html new_checkbox
    return

# Reload and join given parameters and moes
window.reload_selectbox_allowed_params_and_moes = (allowed_params) =>
  if allowed_params.length == 0
    new_select = '<option value=\'\'>' + escapeHtml('There are no parameters satisfying the conditions') + '</option> '
  else
    new_select = '<optgroup label=\'Parameters\'>'
    for iter of moes_info_json
      param = moes_info_json[iter]
      if param.id == 'delimiter'
        new_select = new_select + '</optgroup> <optgroup label=\'Moes\'>'
      else if param.id in allowed_params
        new_select = new_select + '<option value=\'' + escapeHtml(param.id) + '\'>' + escapeHtml(param.label) + '</option> '
    new_select = new_select + '</optgroup>'

  ### replace old values with new ones (input parameters and moes) ###
  $('.allowed_moes_params_list').each ->
    selected_option = $(this).find(':selected').val()
    $(this).html new_select
    $(this).find('option').filter(->
      $(this).val() == selected_option
    ).attr 'selected', true
    return
  reload_selectbox_parameters();


#reload and join parameters and moes
window.reload_selectbox_params_and_moes = ->
  #moes_info_json is global array of json with info (label id type of) parameters (EM global variable)
  new_select = '<optgroup label=\'Parameters\'>'
  for iter of moes_info_json
    param = moes_info_json[iter]
    if param.id == 'delimiter'
      new_select = new_select + '</optgroup> <optgroup label=\'Moes\'>'
    else
      new_select = new_select + '<option value=\'' + escapeHtml(param.id) + '\'>' + escapeHtml(param.label) + '</option> '
  new_select = new_select + '</optgroup>'

  ### replace old values with new ones (input parameters and moes) ###
  $('.moes_params_list').each ->
    selected_option = $(this).find(':selected').val()
    $(this).html new_select
    $(this).find('option').filter(->
      $(this).val() == selected_option
    ).attr 'selected', true
    return



#reload separately parameters and moes
window.reload_selectbox_parameters = ->
  new_moe_select = ''
  new_param_select = ''
  for iter of moes_info_json
    param = moes_info_json[iter]
    if param.type == 'input_parameter'
      new_param_select = new_param_select + '<option value=\'' + escapeHtml(param.id) + '\'>' + escapeHtml(param.label) + '</option> '
    if param.type == 'moes_parameter'
      new_moe_select = new_moe_select + '<option value=\'' + escapeHtml(param.id) + '\'>' + escapeHtml(param.label) + '</option> '

  ### replace old values with new ones (moes) ###
  $('.moe_info_list').each ->
    selected_option = $(this).find(':selected').val()
    $(this).html new_moe_select
    $(this).find('option').filter(->
      $(this).val() == selected_option
    ).attr 'selected', true
    return

  ### replace old values with new ones (input parameters) ###
  $('.param_info_list').each ->
    selected_option = $(this).find(':selected').val()
    $(this).html new_param_select
    $(this).find('option').filter(->
      $(this).val() == selected_option
    ).attr 'selected', true
    return




window.getMoesInfoJson = (input_params, output_params) =>
  moes_info_json_tmp = []
  for i in [0..input_params.length-1]
    moes_info_json_tmp.push({label: input_params[i], id: input_params[i], type: "input_parameter"})
  moes_info_json_tmp.push({ label: "-----------", id: "nil", type: "" })
  for i in [0..output_params.length-1]
    moes_info_json_tmp.push({label: output_params[i], id: output_params[i], type: "moes_parameter"})
  moes_info_json_tmp


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


