CLASS bfs_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    TYPES: BEGIN OF node,
             id         TYPE string,
             neighbours TYPE stringtab,
           END OF node.
    TYPES graph_nodes TYPE STANDARD TABLE OF node WITH EMPTY KEY.

    TYPES: BEGIN OF parent_node,
             node        TYPE string,
             parent      TYPE string,
             distance_to TYPE i,
           END OF parent_node.
    TYPES parent_nodes TYPE HASHED TABLE OF parent_node WITH UNIQUE KEY table_line.

    DATA cut TYPE REF TO yif_mbh_bfs.
    DATA graph TYPE graph_nodes.

    METHODS setup.



    METHODS detect_shortest_step_to_goal FOR TESTING.
    METHODS recreate_shortest_path FOR TESTING.
    METHODS use_non_numeric_graph FOR TESTING.

ENDCLASS.

CLASS bfs_test IMPLEMENTATION.

  METHOD setup.
    graph = VALUE #( ( id = |1| neighbours = VALUE #( ( |2| ) ( |3| ) ) )
                     ( id = |2| neighbours = VALUE #( ( |1| ) ( |4| ) ( |5| ) ) )
                     ( id = |3| neighbours = VALUE #( ( |1| ) ( |7| ) ) )
                     ( id = |4| neighbours = VALUE #( ( |2| ) ( |8| ) ) )
                     ( id = |5| neighbours = VALUE #( ( |2| ) ( |6| ) ( |7| ) ) )
                     ( id = |6| neighbours = VALUE #( ( |5| ) ( |8| ) ( |9| ) ) )
                     ( id = |7| neighbours = VALUE #( ( |2| ) ( |5| ) ( |9| ) ) )
                     ( id = |8| neighbours = VALUE #( ( |4| ) ( |6| ) ) )
                     ( id = |9| neighbours = VALUE #( ( |6| ) ( |7| ) ) ) ).
    cut = NEW ycl_mbh_bfs_simple( graph ).
  ENDMETHOD.

  METHOD detect_shortest_step_to_goal.
    cl_abap_unit_assert=>assert_equals( exp = 3 act = cut->get_distance_of_shortest_path( start_node = |1| goal = |9| )  ).
  ENDMETHOD.

  METHOD recreate_shortest_path.
    DATA(expected_path) = VALUE stringtab( ( |1| ) ( |3| ) ( |7| ) ( |9| ) ).
    cl_abap_unit_assert=>assert_equals( exp = expected_path act = cut->get_nodes_of_shortest_path( start_node = |1| goal = |9| ) ).
  ENDMETHOD.

  METHOD use_non_numeric_graph.
    graph = VALUE #( ( id = |A| neighbours = VALUE #( ( |B| ) ( |C| ) ) )
                     ( id = |B| neighbours = VALUE #( ( |A| ) ( |D| ) ( |E| ) ) )
                     ( id = |C| neighbours = VALUE #( ( |A| ) ( |G| ) ) )
                     ( id = |D| neighbours = VALUE #( ( |B| ) ( |H| ) ) )
                     ( id = |E| neighbours = VALUE #( ( |B| ) ( |F| ) ( |G| ) ) )
                     ( id = |F| neighbours = VALUE #( ( |E| ) ( |H| ) ( |I| ) ) )
                     ( id = |G| neighbours = VALUE #( ( |B| ) ( |E| ) ( |I| ) ) )
                     ( id = |H| neighbours = VALUE #( ( |D| ) ( |F| ) ) )
                     ( id = |I| neighbours = VALUE #( ( |F| ) ( |G| ) ) ) ).
    cut = NEW ycl_mbh_bfs_simple( graph ).
    DATA(expected_path) = VALUE stringtab( ( |A| ) ( |C| ) ( |G| ) ( |I| ) ).
    cl_abap_unit_assert=>assert_equals( exp = expected_path act = cut->get_nodes_of_shortest_path( start_node = |A| goal = |I| ) ).
  ENDMETHOD.

ENDCLASS.
