# hook to the framework base clases
require 'dradis-plugins'

# load this add-on's engine
require 'dradis/plugins/acunetix'

# load supporting Acunetix classes
require 'acunetix/concerns/cleanup'
require 'acunetix/report_item'
require 'acunetix/scan'
require 'acunetix/vulnerability'
