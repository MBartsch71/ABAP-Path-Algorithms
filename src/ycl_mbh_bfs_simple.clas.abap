CLASS ycl_mbh_bfs_simple DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES yif_mbh_bfs.

    METHODS constructor IMPORTING graph TYPE yif_mbh_bfs=>graph_nodes.

  PRIVATE SECTION.
    DATA graph TYPE yif_mbh_bfs=>graph_nodes.
    DATA queue TYPE SORTED TABLE OF string WITH NON-UNIQUE KEY primary_key COMPONENTS table_line.
    DATA visited TYPE yif_mbh_bfs=>visited_nodes.
    DATA parents TYPE yif_mbh_bfs=>parent_nodes.

    METHODS perform_path_search IMPORTING start_node TYPE string.

    METHODS enqueue IMPORTING neighbours TYPE stringtab.

    METHODS dequeue RETURNING VALUE(result) TYPE string.

    METHODS already_visited IMPORTING node          TYPE string
                            RETURNING VALUE(result) TYPE abap_bool.

    METHODS record_visited_node IMPORTING node TYPE string.

    METHODS get_neighbours_from_node IMPORTING node          TYPE string
                                     RETURNING VALUE(result) TYPE stringtab.

    METHODS build_parent_map IMPORTING parent_node TYPE string
                                       nodes       TYPE stringtab.

    METHODS initialization IMPORTING start_node TYPE string.

    METHODS initialize_queue IMPORTING start_node TYPE string.

    METHODS initialize_parent_structure IMPORTING start_node TYPE string.

    METHODS process_graph.

    METHODS filter_paths_to_node IMPORTING node          TYPE string
                                 RETURNING VALUE(result) TYPE yif_mbh_bfs=>parent_nodes_asc_distance.

    METHODS add_step_to_result IMPORTING paths_to_target TYPE yif_mbh_bfs=>parent_nodes_asc_distance
                                         current_result  TYPE stringtab
                               RETURNING VALUE(result)   TYPE stringtab.

    METHODS determine_next_parent IMPORTING paths_to_target TYPE yif_mbh_bfs=>parent_nodes_asc_distance
                                  RETURNING VALUE(result)   TYPE string.

    METHODS determine_shortest_distance IMPORTING goal          TYPE string
                                        RETURNING VALUE(result) TYPE string.

    METHODS determine_nodes_to_goal IMPORTING goal          TYPE string
                                    RETURNING VALUE(result) TYPE stringtab.

ENDCLASS.



CLASS ycl_mbh_bfs_simple IMPLEMENTATION.

  METHOD constructor.
    me->graph = graph.
  ENDMETHOD.

  METHOD yif_mbh_bfs~get_distance_of_shortest_path.
    perform_path_search( start_node ).
    result = determine_shortest_distance( goal ).
  ENDMETHOD.

  METHOD yif_mbh_bfs~get_nodes_of_shortest_path.
    perform_path_search( start_node ).
    result = determine_nodes_to_goal( goal ).
  ENDMETHOD.

  METHOD perform_path_search.
    initialization( start_node ).
    process_graph( ).
  ENDMETHOD.

  METHOD initialization.
    initialize_queue( start_node ).
    initialize_parent_structure( start_node ).
  ENDMETHOD.

  METHOD determine_shortest_distance.
    DATA(paths_to_target) = filter_paths_to_node( goal ).
    result = paths_to_target[ 1 ]-distance_to.
  ENDMETHOD.

  METHOD determine_nodes_to_goal.
    DATA(next_parent) = goal.

    WHILE next_parent IS NOT INITIAL.
      DATA(paths_to_target) = filter_paths_to_node( next_parent ).
      next_parent = determine_next_parent( paths_to_target ).
      result = add_step_to_result( paths_to_target = paths_to_target
                                   current_result  = result ).
    ENDWHILE.
  ENDMETHOD.

  METHOD filter_paths_to_node.
    result  = FILTER yif_mbh_bfs=>parent_nodes_asc_distance( parents WHERE node = node  ).
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

  METHOD initialize_queue.
    queue = VALUE #( ( start_node ) ).
  ENDMETHOD.

  METHOD initialize_parent_structure.
    parents = VALUE #( ( node = start_node parent = || ) ).
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
    result = graph[ id = node ]-neighbours.
  ENDMETHOD.

  METHOD build_parent_map.
    LOOP AT nodes REFERENCE INTO DATA(node).
      IF already_visited( node->* ).
        CONTINUE.
      ENDIF.
      DATA(distance) = parents[ node = parent_node ]-distance_to + 1.
      parents = VALUE #( BASE parents ( node        = node->*
                                        parent      = parent_node
                                        distance_to = distance ) ).
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
