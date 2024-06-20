CLASS bfs_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    TYPES: neighbours TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    TYPES: BEGIN OF node,
             id         TYPE i,
             neighbours TYPE neighbours,
           END OF node.
    TYPES graph_nodes TYPE STANDARD TABLE OF node WITH EMPTY KEY.

    TYPES: BEGIN OF parent_node,
             node        TYPE i,
             parent      TYPE i,
             distance_to TYPE i,
           END OF parent_node.
    TYPES parent_nodes TYPE HASHED TABLE OF parent_node WITH UNIQUE KEY table_line.

    DATA cut TYPE REF TO ycl_mbh_bfs_Simple.
    DATA graph TYPE graph_nodes.

    METHODS setup.
    METHODS can_create_object FOR TESTING.
    METHODS visit_all_nodes FOR TESTING.
    METHODS populate_parent_nodes FOR TESTING.
    METHODS find_shortest_path FOR TESTING.

ENDCLASS.

CLASS bfs_test IMPLEMENTATION.

  METHOD setup.
    graph = VALUE #( ( id = 1 neighbours = VALUE #( ( 2 ) ( 3 ) ) )
                     ( id = 2 neighbours = VALUE #( ( 4 ) ( 5 ) ) )
                     ( id = 3 neighbours = VALUE #( ( 1 ) ( 7 ) ) )
                     ( id = 4 neighbours = VALUE #( ( 2 ) ( 8 ) ) )
                     ( id = 5 neighbours = VALUE #( ( 2 ) ( 6 ) ( 7 ) ) )
                     ( id = 6 neighbours = VALUE #( ( 5 ) ( 8 ) ( 9 ) ) )
                     ( id = 7 neighbours = VALUE #( ( 2 ) ( 5 ) ( 9 ) ) )
                     ( id = 8 neighbours = VALUE #( ( 4 ) ( 6 ) ) )
                     ( id = 9 neighbours = VALUE #( ( 6 ) ( 7 ) ) ) ).
    cut = NEW #( graph ).
  ENDMETHOD.

  METHOD can_create_object.
    cl_abap_unit_assert=>assert_bound( act = cut msg = |The object should be bound!| ).
  ENDMETHOD.

  METHOD visit_all_nodes.
    DATA(expected_path) = VALUE stringtab( ( |1| ) ( |2| ) ( |3| )
                                           ( |4| ) ( |5| ) ( |6| )
                                           ( |7| ) ( |8| ) ( |9| ) ).
    cl_abap_unit_assert=>assert_equals( exp = expected_path act = cut->bfs( )  ).
  ENDMETHOD.

  METHOD populate_parent_nodes.
    DATA(expected_parent_nodes) = VALUE parent_nodes( ( node = 1 parent = 0 distance_to = 0 )
                                                      ( node = 2 parent = 1 distance_to = 1 )
                                                      ( node = 3 parent = 1 distance_to = 1 )
                                                      ( node = 4 parent = 2 distance_to = 2 )
                                                      ( node = 5 parent = 2 distance_to = 2 )
                                                      ( node = 6 parent = 5 distance_to = 3 )
                                                      ( node = 7 parent = 3 distance_to = 2 )
                                                      ( node = 7 parent = 5 distance_to = 3 )
                                                      ( node = 8 parent = 4 distance_to = 3 )
                                                      ( node = 8 parent = 6 distance_to = 4 )
                                                      ( node = 9 parent = 6 distance_to = 4 )
                                                      ( node = 9 parent = 7 distance_to = 3 ) ).
    cut->bfs( ).
    cl_abap_unit_assert=>assert_equals( exp = expected_parent_nodes act = cut->get_parent_nodes( ) ).
  ENDMETHOD.

  METHOD find_shortest_path.
    cl_abap_unit_assert=>assert_equals( exp = 3 act = cut->find_shortest_path( goal = 9 )  ).
  ENDMETHOD.

ENDCLASS.
