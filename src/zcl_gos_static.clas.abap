class ZCL_GOS_STATIC definition
  public
  final
  create public .

*"* public components of class ZCL_GOS_STATIC
*"* do not include other source files here!!!
public section.

  type-pools ABAP .
  class-methods GET_FILES
    importing
      !I_TYPE type SIMPLE
      !I_ID type SIMPLE
      !I_CONTENT type ABAP_BOOL default ABAP_FALSE
    exporting
      value(ET_FILES) type ZCL_FILE_STATIC=>TT_FILES
    raising
      ZCX_GENERIC .
  class-methods GET_FILE
    importing
      !I_ID type SIMPLE
      !I_CONTENT type ABAP_BOOL default ABAP_FALSE
    returning
      value(ES_FILE) type ZCL_FILE_STATIC=>TS_FILE
    raising
      ZCX_GENERIC .
protected section.
*"* protected components of class ZCL_GOS_STATIC
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_GOS_STATIC
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_GOS_STATIC IMPLEMENTATION.


method get_file.

  data l_doc_id type so_entryid.
  l_doc_id = i_id.

  data ls_data type sofolenti1.
  data lt_header type table of solisti1.
  data lt_content type soli_tab.
  data lt_content_x type solix_tab.
  call function 'SO_DOCUMENT_READ_API1'
    exporting
      document_id                = l_doc_id
    importing
      document_data              = ls_data
    tables
      object_header              = lt_header
      object_content             = lt_content
      contents_hex               = lt_content_x
    exceptions
      document_id_not_exist      = 1
      operation_no_authorization = 2
      x_error                    = 3
      others                     = 4.
  if sy-subrc ne 0.
    zcx_generic=>raise( ).
  endif.

  " Èìÿ ôàéëà
  data ls_header like line of lt_header.
  loop at lt_header into ls_header where line cs '&SO_FILENAME='.
    es_file-name = ls_header-line+13.
    exit.
  endloop.

  " Ðàçìåð
  es_file-size = ls_data-doc_size.

  " Ñîäåðæèìîå
  if i_content eq abap_true.

    if lt_content_x is not initial.

      call function 'SCMS_BINARY_TO_XSTRING'
        exporting
          input_length = es_file-size
        importing
          buffer       = es_file-data
        tables
          binary_tab   = lt_content_x
        exceptions
          failed       = 1
          others       = 2.
      if sy-subrc ne 0.
        zcx_generic=>raise( ).
      endif.

    elseif lt_content is not initial.

      call function 'SCMS_TEXT_TO_XSTRING'
        importing
          buffer   = es_file-data
        tables
          text_tab = lt_content
        exceptions
          failed   = 1
          others   = 2.
      if sy-subrc ne 0.
        zcx_generic=>raise( ).
      endif.

    endif.

  endif.

endmethod.


method get_files.

  data ls_object type sibflporb.
  ls_object-catid  = 'BO'.
  ls_object-typeid = i_type.
  ls_object-instid = i_id.

  data lt_relations type obl_t_relt.
  data ls_relation like line of lt_relations.
  ls_relation     = 'IEQ'.
  ls_relation-low = 'ATTA'.     "Attachements
  insert ls_relation into table lt_relations.

  try.
      data lt_links type obl_t_link.
      cl_binary_relation=>read_links(
        exporting
          is_object           = ls_object
          it_relation_options = lt_relations
        importing
          et_links            = lt_links ).
      data lx_root type ref to cx_root.
    catch cx_root into lx_root.
      zcx_generic=>raise( ix_root = lx_root ).
  endtry.

  data ls_link like line of lt_links.
  loop at lt_links into ls_link.

    field-symbols <ls_file> like line of et_files.
    append initial line to et_files assigning <ls_file>.

    <ls_file> =
      get_file(
        i_id      = ls_link-instid_b
        i_content = i_content ).

  endloop.

endmethod.
ENDCLASS.
