CLASS bfs_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    TYPES: neighbours TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    TYPES: BEGIN OF node,
             id         TYPE i,
             neighbours TYPE neighbours,
           END OF node.
    TYPES graph TYPE STANDARD TABLE OF node WITH EMPTY KEY.

    METHODS can_create_object FOR TESTING.
    METHODS visit_all_nodes FOR TESTING.

ENDCLASS.

CLASS bfs_test IMPLEMENTATION.

  METHOD can_create_object.
    DATA(cut) = NEW ycl_mbh_bfs_simple( ).
    cl_abap_unit_assert=>assert_bound( act = cut msg = |The object should be bound!| ).

  ENDMETHOD.

  METHOD visit_all_nodes.
    DATA(cut) = NEW ycl_mbh_bfs_simple( ).
    DATA(graph) = VALUE graph( ( id = 1 neighbours = VALUE #( ( 2 ) ( 3 ) ) )
                               ( id = 2 neighbours = VALUE #( ( 4 ) ( 5 ) ) )
                               ( id = 3 neighbours = VALUE #( ( 1 ) ( 7 ) ) )
                               ( id = 4 neighbours = VALUE #( ( 2 ) ( 8 ) ) )
                               ( id = 5 neighbours = VALUE #( ( 2 ) ( 6 ) ( 7 ) ) )
                               ( id = 6 neighbours = VALUE #( ( 5 ) ( 8 ) ( 9 ) ) )
                               ( id = 7 neighbours = VALUE #( ( 2 ) ( 5 ) ( 8 ) ( 9 ) ) )
                               ( id = 8 neighbours = VALUE #( ( 4 ) ( 6 ) ) )
                               ( id = 9 neighbours = VALUE #( ( 6 ) ( 7 ) ) ) ).
    DATA(expected_path) = VALUE stringtab( ( |1| ) ( |2| ) ( |3| )
                                           ( |4| ) ( |5| ) ( |7| )
                                           ( |8| ) ( |6| ) ( |9| ) ).
    cl_abap_unit_assert=>assert_equals( exp = expected_path act = cut->bfs( graph = graph ) ).
  ENDMETHOD.

ENDCLASS.
