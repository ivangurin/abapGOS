class ZCL_GOS definition
  public
  abstract
  create public .

*"* public components of class ZCL_GOS
*"* do not include other source files here!!!
public section.

  data OBJECT type BORIDENT read-only .
  data R_GOS type ref to CL_GOS_MANAGER read-only .

  type-pools ABAP .
  methods CONSTRUCTOR
    importing
      !I_TYPE type SIMPLE
      !I_KEY type SIMPLE
      !I_FILE type ABAP_BOOL default ABAP_FALSE
      !I_NOTE type ABAP_BOOL default ABAP_FALSE
    raising
      ZCX_GENERIC .
  methods ADD_FILE
    importing
      !I_COMMIT type ABAP_BOOL default ABAP_FALSE
    raising
      ZCX_GENERIC .
  methods GET_FILES .
  methods ADD_NOTE
    importing
      !I_COMMIT type ABAP_BOOL default ABAP_FALSE
    raising
      ZCX_GENERIC .
  methods SET_EDIT_MODE .
  methods SET_DISPLAY_MODE .
  methods LIST
    importing
      !I_COMMIT type ABAP_BOOL default ABAP_FALSE
    raising
      ZCX_GENERIC .
  methods CLOSE .
protected section.
*"* protected components of class ZCL_GOS
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_GOS
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_GOS IMPLEMENTATION.


method add_file.

  data l_a type abap_bool.
  r_gos->start_service_direct(
    exporting
      ip_service       = 'PCATTA_CREA'
      is_object        = object
    importing
      ep_available     = l_a
    exceptions
      no_object        = 1
      object_invalid   = 2
      execution_failed = 3
      others           = 4 ).
  if sy-subrc ne 0.
    zcx_generic=>raise( ).
  endif.

  if i_commit eq abap_true.
    zcl_abap_static=>commit( ).
  endif.

endmethod.


method add_note.

  r_gos->start_service_direct(
    exporting
      ip_service       = 'NOTE_CREA'
      is_object        = object
    exceptions
      no_object        = 1
      object_invalid   = 2
      execution_failed = 3
      others           = 4 ).
  if sy-subrc ne 0.
    zcx_generic=>raise( ).
  endif.

  if i_commit eq abap_true.
    zcl_abap_static=>commit( ).
  endif.

endmethod.


method close.

  r_gos->unpublish( ).

  free r_gos.

endmethod.


method constructor.

  object-objtype = i_type.
  object-objkey  = i_key.

  data lt_services type tgos_sels.
  data ls_service like line of lt_services.
  ls_service = 'IEQ'.
  ls_service-low = 'CREATE_ATTA'.
  insert ls_service into table lt_services.
  ls_service-low = 'VIEW_ATTA'.
  insert ls_service into table lt_services.

  if i_file eq abap_true.
    ls_service-low = 'PCATTA_CREA'.
    insert ls_service into table lt_services.
  endif.

  if i_note eq abap_true.
    ls_service-low = 'NOTE_CREA'.
    insert ls_service into table lt_services.
  endif.

  create object r_gos
    exporting
      is_object            = object
      it_service_selection = lt_services
    exceptions
      others               = 1.
  if sy-subrc ne 0.
    zcx_generic=>raise( ).
  endif.

  set_display_mode( ).

endmethod.


method get_files.

    data lr_attachments type ref to cl_gos_srv_attachment_list.
    create object lr_attachments.

  endmethod.


method list.

  r_gos->start_service_direct(
    exporting
      ip_service       = 'VIEW_ATTA'
      is_object        = object
    exceptions
      no_object        = 1
      object_invalid   = 2
      execution_failed = 3
      others           = 4 ).
  if sy-subrc ne 0.
    zcx_generic=>raise( ).
  endif.

  if i_commit eq abap_true.
    zcl_abap_static=>commit( ).
  endif.

endmethod.


method set_display_mode.

  r_gos->set_rw_mode( 'D' ).

endmethod.


method set_edit_mode.

  r_gos->set_rw_mode( 'E' ).

endmethod.
ENDCLASS.
