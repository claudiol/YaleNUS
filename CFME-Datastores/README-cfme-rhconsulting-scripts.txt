= Cloudforms/ManageIQ rhconsulting rake scripts

These scripts are useful to import/export specific items

== Install
* Copy the .rake files to /var/www/miq/vmdb/lib/tasks


== Example Exports
You can use the provided export_all.sh.

----
BUILDDIR=/tmp/CFME-build

rm -fR ${BUILDDIR}
mkdir -p ${BUILDDIR}

cd /var/www/miq/vmdb
bin/rake rhconsulting:service_catalogs:export[${BUILDDIR}/service_catalogs]
bin/rake rhconsultingialogs:export[${BUILDDIR}/dialogs]
bin/rake rhconsulting:roles:export[${BUILDDIR}/roles/roles.yml]
bin/rake rhconsulting:tags:export[${BUILDDIR}/tags/tags.yml]
bin/rake rhconsulting:buttons:export[${BUILDDIR}/buttons/buttons.yml]
----

== Example Imports
You can use the provided export_all.sh.

----
BUILDDIR=/tmp/CFME-build

cd /var/www/miq/vmdb
bin/rake rhconsulting:service_catalogs:import[${BUILDDIR}/service_catalogs]
bin/rake rhconsultingialogs:import[${BUILDDIR}/dialogs]
bin/rake rhconsulting:roles:import[${BUILDDIR}/roles/roles.yml]
bin/rake rhconsulting:tags:import[${BUILDDIR}/tags/tags.yml]
bin/rake rhconsulting:buttons:import[${BUILDDIR}/buttons/buttons.yml]
----

----

