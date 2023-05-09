--This view monitors the activity in the queues
create view WLM_QUEUE_STATE_VW as
select (config.service_class-5) as queue
, trim (class.condition) as description
, config.num_query_tasks as slots
, config.query_working_mem as mem
, config.max_execution_time as max_time
, config.user_group_wild_card as "user_*"
, config.query_group_wild_card as "query_*"
, state.num_queued_queries queued
, state.num_executing_queries executing
, state.num_executed_queries executed
from
STV_WLM_CLASSIFICATION_CONFIG class,
STV_WLM_SERVICE_CLASS_CONFIG config,
STV_WLM_SERVICE_CLASS_STATE state
where
class.action_service_class = config.service_class
and class.action_service_class = state.service_class
and config.service_class > 4
order by config.service_class;

--This view returns information from the STV_WLM_QUERY_STATE system table.
--This view can be used to monitor the queries that are running.
--This query returns a self-referential result. The query that is currently executing is the SELECT
--statement from this view. A query on this view will always return at least one result.

create view WLM_QUERY_STATE_VW as
select query, (service_class-5) as queue, slot_count, trim(wlm_start_time) as start_time,
trim(state) as state, trim(queue_time) as queue_time, trim(exec_time) as exec_time
from stv_wlm_query_state;

select * from wlm_queue_state_vw;
select * from wlm_query_state_vw;

--Disable result caching
set enable_result_cache_for_session to off;

--Execute below queries in a new tab and use the monitoring queries in another tab

--Test query 1
set enable_result_cache_for_session to off;
select avg(l.priceperticket*s.qtysold) from listing l, sales s where l.listid < 100000;

--Test query 2
set enable_result_cache_for_session to off;
set query_group to test;
select avg(l.priceperticket*s.qtysold) from listing l, sales s where l.listid < 40000;

--Test query 3
set enable_result_cache_for_session to off;
reset query_group;
select avg(l.priceperticket*s.qtysold) from listing l, sales s where l.listid < 40000;

--Test query 4
create user adminwlm createuser password '123Admin';
create group admin;
alter group admin add user adminwlm;
set session authorization 'adminwlm';
set enable_result_cache_for_session to off;
select avg(l.priceperticket*s.qtysold) from listing l, sales s where l.listid < 40000;