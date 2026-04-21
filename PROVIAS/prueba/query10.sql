set rowcount 20

select*from sys.key_constraints -- where type = 'uq'
select*From sys.default_constraints
select*From sys.foreign_keys
