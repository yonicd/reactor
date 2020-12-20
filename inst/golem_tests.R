library(reactor)

obj <- init_reactor()%>%
  set_golem_args(package_name = 'puzzlemath')%>%
  set_chrome_driver(
    chromever = chrome_version(),
    opts = chrome_options(headless = FALSE)
  )

obj <- obj%>%
  start_reactor()

obj%>%
  expect_reactivity('plot',1)%>%
  expect_reactivity('draw',1)

obj%>%
  click_id('draw')%>%
  expect_reactivity('draw',2)

obj%>%
  set_id_value('range',c(10,20))%>%
  expect_reactivity('plot',2)%>%
  expect_reactivity('draw',3)

current_ans <- obj%>%
  query_output_id('ques')%>%
  gsub('\\?','',.)%>%
  parse(text = .)%>%
  eval()

obj%>%
  set_id_value('ans',current_ans)

obj%>%
  query("$('#anspanel').css('border-color')",flatten = TRUE)%>%
  testthat::expect_equal(expected = "rgb(0, 128, 0)")

obj%>%
  kill_app()
