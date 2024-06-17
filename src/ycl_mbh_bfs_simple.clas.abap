CLASS ycl_mbh_bfs_simple DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: neighbours TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    TYPES: BEGIN OF node,
             id         TYPE i,
             neighbours TYPE neighbours,
           END OF node.
    TYPES graph TYPE STANDARD TABLE OF node WITH EMPTY KEY.

    TYPES: BEGIN OF visited_node,
             id TYPE i,
           END OF visited_node.
    TYPES visited_nodes TYPE HASHED TABLE OF visited_node WITH UNIQUE KEY table_line.

    METHODS bfs IMPORTING graph         TYPE graph
                RETURNING VALUE(result) TYPE stringtab.

  PRIVATE SECTION.
    DATA queue TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA visited TYPE visited_nodes.

    METHODS dequeue RETURNING VALUE(result) TYPE i.

    METHODS already_visited IMPORTING node          TYPE i
                            RETURNING VALUE(result) TYPE abap_bool.

    METHODS enqueue IMPORTING neighbours TYPE neighbours.

    METHODS record_visited_node IMPORTING node TYPE i.

    METHODS get_neighbours_from_node IMPORTING graph         TYPE graph
                                               node          TYPE i
                                     RETURNING VALUE(result) TYPE neighbours.
ENDCLASS.



CLASS ycl_mbh_bfs_simple IMPLEMENTATION.

  METHOD bfs.

    queue = VALUE #( ( graph[ 1 ]-id ) ).

    WHILE queue IS NOT INITIAL.

      DATA(node) = dequeue( ).
      IF already_visited( node ).
        CONTINUE.
      ENDIF.

      record_visited_node( node ).

      DATA(neighbours) =  get_neighbours_from_node( graph = graph
                                                    node  = node ).
      enqueue( neighbours ).

    ENDWHILE.

    result = VALUE #( FOR line IN visited ( condense( CONV string( line-id ) ) ) ).
  ENDMETHOD.

  METHOD dequeue.
    result = queue[ 1 ].
    DELETE queue INDEX 1.
  ENDMETHOD.

  METHOD already_visited.
    result = xsdbool( line_exists( visited[ id = node ] ) ).
  ENDMETHOD.

  METHOD enqueue.
    LOOP AT neighbours REFERENCE INTO DATA(neighbour_node).
      queue = VALUE #( BASE queue ( neighbour_node->* ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD record_visited_node.
    visited = VALUE #( BASE visited ( id = node ) ).
  ENDMETHOD.

  METHOD get_neighbours_from_node.
    result = graph[ node ]-neighbours.
  ENDMETHOD.

ENDCLASS.
