CLASS ycl_mbh_bfs_simple DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: neighbours TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    TYPES: BEGIN OF node,
             id         TYPE i,
             neighbours TYPE neighbours,
           END OF node.
    TYPES graph_nodes TYPE STANDARD TABLE OF node WITH EMPTY KEY.

    TYPES: BEGIN OF visited_node,
             id TYPE i,
           END OF visited_node.
    TYPES visited_nodes TYPE SORTED TABLE OF visited_node WITH UNIQUE KEY table_line.

    TYPES: BEGIN OF parent_node,
             node        TYPE i,
             parent      TYPE i,
             distance_to TYPE i,
           END OF parent_node.
    TYPES parent_nodes TYPE SORTED TABLE OF parent_node WITH UNIQUE KEY table_line
                                                        WITH NON-UNIQUE SORTED KEY distance COMPONENTS node distance_to.

    METHODS constructor IMPORTING graph TYPE graph_nodes.

    METHODS bfs RETURNING VALUE(result) TYPE stringtab.

    METHODS get_parent_nodes RETURNING VALUE(result) TYPE parent_nodes.
    METHODS find_shortest_path
      IMPORTING
        goal          TYPE i
      RETURNING
        VALUE(result) TYPE i.


  PRIVATE SECTION.
    DATA graph TYPE graph_nodes.
    DATA queue TYPE SORTED TABLE OF i WITH NON-UNIQUE KEY primary_key COMPONENTS table_line.
    DATA visited TYPE visited_nodes.
    DATA parents TYPE parent_nodes.

    METHODS dequeue RETURNING VALUE(result) TYPE i.

    METHODS already_visited IMPORTING node          TYPE i
                            RETURNING VALUE(result) TYPE abap_bool.

    METHODS enqueue IMPORTING neighbours TYPE neighbours.

    METHODS record_visited_node IMPORTING node TYPE i.

    METHODS get_neighbours_from_node IMPORTING node          TYPE i
                                     RETURNING VALUE(result) TYPE neighbours.


    METHODS build_parent_map
      IMPORTING
        parent_node TYPE i
        nodes       TYPE ycl_mbh_bfs_simple=>neighbours.
ENDCLASS.



CLASS ycl_mbh_bfs_simple IMPLEMENTATION.

  METHOD constructor.
    me->graph = graph.
  ENDMETHOD.

  METHOD bfs.

    queue = VALUE #( ( graph[ 1 ]-id ) ).
    parents = VALUE #( ( node = 1 parent = 0 ) ).

    WHILE queue IS NOT INITIAL.

      DATA(node) = dequeue( ).
      IF already_visited( node ).
        CONTINUE.
      ENDIF.

      record_visited_node( node ).

      DATA(neighbours) =  get_neighbours_from_node( node ).
      build_parent_map( parent_node = node
                        nodes       = neighbours ).
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

  METHOD get_parent_nodes.
    result = parents.
  ENDMETHOD.

  METHOD build_parent_map.
    LOOP AT nodes REFERENCE INTO DATA(node).
      IF already_visited( node->* ).
        CONTINUE.
      ENDIF.
      DATA(distance) = parents[ node = parent_node ]-distance_to + 1.
      parents = VALUE #( BASE parents ( node = node->* parent = parent_node distance_to = distance ) ).
    ENDLOOP.
  ENDMETHOD.


  METHOD find_shortest_path.
    DATA paths_to_target TYPE SORTED TABLE OF parent_node WITH UNIQUE KEY primary_key COMPONENTS node distance_to.

    bfs( ).
    paths_to_target = FILTER #( get_parent_nodes( ) USING KEY distance WHERE node = goal  ).
    result = paths_to_target[ 1 ]-distance_to.
  ENDMETHOD.

ENDCLASS.
