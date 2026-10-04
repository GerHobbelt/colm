ASCIIDOCTOR = @ASCIIDOCTOR@

OUTPUT=html5
OPTIONS=\
	-a max-width=800px \
	-a source-highlighter=rouge \
	-a webfonts!

IN_FILES = \
	0_00_welcome.adoc 0_06_scope.adoc 1_05_variables.adoc \
	3_00_language_transformation.adoc 8_00_advanced_topics.adoc \
	9_00_q_and_a.adoc 0_01_installing.adoc 1_00_language_overview.adoc \
	1_06_iterators.adoc 3_01_lex.adoc 8_01_embedding.adoc \
	0_02_vim_syntax.adoc 1_01_statements.adoc 2_00_types.adoc \
	3_02_parse.adoc 8_02_modularity.adoc 0_03_commandline.adoc \
	1_02_expressions.adoc 2_01_basic.adoc 3_03_match.adoc \
	8_03_performance.adoc 0_04_hello_world.adoc 1_03_control_flow.adoc \
	2_02_list_map_struct_alias.adoc 3_04_undo.adoc 8_04_error_handling.adoc \
	0_05_fizzbuzz.adoc 1_04_functions.adoc 2_03_def.adoc \
	3_05_reduction.adoc 8_05_contributing.adoc

# The example programs, each with the output it prints (.exp) and the input
# it reads (.in), if any. The test harness's manual suite runs them, and the
# pages include the programs and their output.
CODE = \
	code/assign.lm           code/assign.exp           code/assign.in \
	code/figure_44.lm        code/figure_44.exp \
	code/fizzbuzz.lm         code/fizzbuzz.exp \
	code/hello_world.lm      code/hello_world.exp \
	code/hello_world_ext.lm  code/hello_world_ext.exp \
	code/nested_scope.lm     code/nested_scope.exp \
	code/poker.lm            code/poker.exp \
	code/reference.lm        code/reference.exp \
	code/scope.lm            code/scope.exp


OUT_FILES = $(IN_FILES:.adoc=.html)

CLEANFILES = $(OUT_FILES)

EXTRA_DIST = $(IN_FILES) $(CODE) CMakeLists.txt

if BUILD_MANUAL

if INSTALL_COLM
doc_DATA = $(OUT_FILES)
endif

SUFFIXES = .html .adoc

# The pages include the example programs and their output. Every page is
# rebuilt when one of them changes, which is simpler than tracking which page
# includes which.
$(OUT_FILES): $(CODE)

.adoc.html:
	$(ASCIIDOCTOR) -b $(OUTPUT) $(OPTIONS) -o $@ $<

endif
