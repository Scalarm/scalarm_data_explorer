

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
  toastr.success("Moes refreshed")

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
  toastr.success 'Parameters refreshed'

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
  toastr.success 'Parameters refreshed'

