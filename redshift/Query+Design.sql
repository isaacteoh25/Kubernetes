select lastname, catname, venuename, venuecity, venuestate, eventname,
month, sum(pricepaid) as buyercost, max(totalprice) as maxtotalprice
from category join event on category.catid = event.catid
join venue on venue.venueid = event.venueid
join sales on sales.eventid = event.eventid
join listing on sales.listid = listing.listid
join date on sales.dateid = date.dateid
join users on users.userid = sales.buyerid
group by lastname, catname, venuename, venuecity, venuestate, eventname, month
having sum(pricepaid)>9999
order by catname, buyercost desc;

select query, elapsed, substring
from svl_qlog
order by query
desc limit 10;

select * from svl_query_summary where query = <queryid> order by stm, seg, step;

select query, stm, seg, step, maxtime, rows, label, is_diskbased, workmem, rows_pre_filter
from svl_query_summary where query = <queryid> order by stm, seg, step;

select * from svl_query_report where query = <queryid> order by segment, step,
elapsed_time, rows;