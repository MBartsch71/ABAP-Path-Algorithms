CLASS ycl_mbh_bfs_simple DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES yif_mbh_bfs.

    METHODS constructor IMPORTING graph TYPE yif_mbh_bfs=>graph_nodes.

  PRIVATE SECTION.
    DATA graph TYPE yif_mbh_bfs=>graph_nodes.
    DATA queue TYPE SORTED TABLE OF i WITH NON-UNIQUE KEY primary_key COMPONENTS table_line.
    DATA visited TYPE yif_mbh_bfs=>visited_nodes.
    DATA parents TYPE yif_mbh_bfs=>parent_nodes.

    METHODS perform_path_search.

    METHODS enqueue IMPORTING neighbours TYPE yif_mbh_bfs=>neighbours.

    METHODS dequeue RETURNING VALUE(result) TYPE i.

    METHODS already_visited IMPORTING node          TYPE i
                            RETURNING VALUE(result) TYPE abap_bool.

    METHODS record_visited_node IMPORTING node TYPE i.

    METHODS get_neighbours_from_node IMPORTING node          TYPE i
                                     RETURNING VALUE(result) TYPE yif_mbh_bfs=>neighbours.

    METHODS build_parent_map IMPORTING parent_node TYPE i
                                       nodes       TYPE yif_mbh_bfs=>neighbours.

    METHODS get_parent_nodes RETURNING VALUE(result) TYPE yif_mbh_bfs=>parent_nodes.

    METHODS initialization.

    METHODS initialize_queue.

    METHODS initialize_parent_structure.

    METHODS process_graph.

    METHODS filter_paths_to_node IMPORTING node          TYPE i
                                 RETURNING VALUE(result) TYPE yif_mbh_bfs=>parent_nodes_asc_distance.

    METHODS add_step_to_result IMPORTING paths_to_target TYPE yif_mbh_bfs=>parent_nodes_asc_distance
                                         current_result  TYPE stringtab
                               RETURNING VALUE(result)   TYPE stringtab.

    METHODS determine_next_parent IMPORTING paths_to_target TYPE yif_mbh_bfs=>parent_nodes_asc_distance
                                  RETURNING VALUE(result)   TYPE i.

ENDCLASS.



CLASS ycl_mbh_bfs_simple IMPLEMENTATION.

  METHOD constructor.
    me->graph = graph.
  ENDMETHOD.

  METHOD yif_mbh_bfs~get_distance_of_shortest_path.
    perform_path_search( ).

    DATA(paths_to_target) = filter_paths_to_node( goal ).
    result = paths_to_target[ 1 ]-distance_to.
  ENDMETHOD.

  METHOD yif_mbh_bfs~get_nodes_of_shortest_path.
    DATA(next_parent) = goal.
    perform_path_search( ).

    WHILE next_parent IS NOT INITIAL.
      DATA(paths_to_target) = filter_paths_to_node( next_parent ).
      next_parent = determine_next_parent( paths_to_target ).
      result = add_step_to_result( paths_to_target = paths_to_target
                                   current_result  = result ).
    ENDWHILE.
  ENDMETHOD.

  METHOD perform_path_search.
    initialization( ).
    process_graph( ).
  ENDMETHOD.

  METHOD filter_paths_to_node.
    result  = FILTER yif_mbh_bfs=>parent_nodes_asc_distance( get_parent_nodes( ) WHERE node = node  ).
  ENDMETHOD.

  METHOD process_graph.
    WHILE queue IS NOT INITIAL.

      DATA(node) = dequeue( ).
      IF already_visited( node ).
        CONTINUE.
      ENDIF.

      record_visited_node( node ).

      DATA(neighbours) = get_neighbours_from_node( node ).
      build_parent_map( parent_node = node
                        nodes       = neighbours ).
      enqueue( neighbours ).
    ENDWHILE.
  ENDMETHOD.

  METHOD initialization.
    initialize_queue( ).
    initialize_parent_structure( ).
  ENDMETHOD.

  METHOD initialize_parent_structure.
    parents = VALUE #( ( node = 1 parent = 0 ) ).
  ENDMETHOD.

  METHOD initialize_queue.
    queue = VALUE #( ( graph[ 1 ]-id ) ).
  ENDMETHOD.

  METHOD enqueue.
    LOOP AT neighbours REFERENCE INTO DATA(neighbour_node).
      queue = VALUE #( BASE queue ( neighbour_node->* ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD dequeue.
    result = queue[ 1 ].
    DELETE queue INDEX 1.
  ENDMETHOD.

  METHOD already_visited.
    result = xsdbool( line_exists( visited[ id = node ] ) ).
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

  METHOD add_step_to_result.
    result = current_result.
    INSERT condense( CONV string( paths_to_target[ 1 ]-node ) ) INTO result INDEX 1.
  ENDMETHOD.

  METHOD determine_next_parent.
    result = paths_to_target[ 1 ]-parent.
  ENDMETHOD.

ENDCLASS.
