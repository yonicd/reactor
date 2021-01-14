library(reactor)

obj <- init_reactor()%>%
  set_golem_args(package_name = 'puzzlemath')%>%
  set_chrome_driver(
    chromever = chrome_version()
  )

obj <- obj%>%
  start_reactor()

obj%>%
  expect_busy_time(0.05)%>%
  expect_reactivity('plot',1)%>%
  expect_reactivity('draw',1)

obj%>%
  click_id('draw')%>%
  expect_busy_time(0.1)%>%
  expect_reactivity('draw',2)

obj%>%
  set_id_value('range',c(10,20))%>%
  expect_busy_time(0.8)%>%
  expect_reactivity('plot',2)%>%
  expect_reactivity('draw',3)

obj%>%
  query_output_id('ques')%>%
  gsub('\\?','',.)%>%
  parse(text = .)%>%
  eval()%>%
  set_id_value(
    obj = obj, 
    id = 'ans'
  )

obj%>%
  query_style_id(
    id = 'anspanel',
    style = 'borderColor',
    flatten = TRUE
  )%>%
  testthat::expect_equal(
    expected = "green"
  )

# check cumulative busy time of app
obj%>%
  expect_busy_time(1.5,history = TRUE)

obj%>%
  kill_app()
