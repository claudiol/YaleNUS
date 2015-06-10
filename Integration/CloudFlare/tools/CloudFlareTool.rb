=begin
	  CloudFlareTool.rb - Ruby/GTK Tool for CloudFlareDNS
	
	  Copyright (c) 2002-2006 Ruby-GNOME2 Project Team
	  This program is licenced under the same licence as Ruby-GNOME2.	
=end
	
require 'gtk3'
require 'CloudFlareDNS'

@debug = false

options={}
options[:config_file] = '../test/cloudflare-config.yaml'
	
window = Gtk::Window.new("CloudFlareDNS Tool")
window.border_width = 0
	
box1 = Gtk::Box.new(:vertical, 0)
window.add(box1)

box2 = Gtk::Box.new(:vertical, 10)
box2.border_width = 10
box1.pack_start(box2, true, true, 0)
	
scrolled_win = Gtk::ScrolledWindow.new
scrolled_win.set_policy(:automatic,:automatic)
box2.pack_start(scrolled_win, true, true, 0)
	
# Model has FQDN (String), IP Address (String), ID (String)
model = Gtk::ListStore.new(String,String,String)
column = Gtk::TreeViewColumn.new("FQDN",
                                 Gtk::CellRendererText.new, {:text => 0})
column2 = Gtk::TreeViewColumn.new("IP Address",
                                 Gtk::CellRendererText.new, {:text => 1})
column3 = Gtk::TreeViewColumn.new("Record ID",
                                 Gtk::CellRendererText.new, {:text => 2})
treeview = Gtk::TreeView.new(model)
treeview.append_column(column)
treeview.append_column(column2)
treeview.append_column(column3)
treeview.selection.set_mode(:single)
scrolled_win.add_with_viewport(treeview)

# Lets use the CloudFlareDNS to get DNS records ...	
cfdns = CloudFlareDNS.new(options)

page_number = 1
response = cfdns.list_all_dns_records(page_number)

if response['success']
  puts "Success" if @debug
  records = response['result']
  result_info = response['result_info']
  total_count = result_info['total_count']
  count = result_info['count']

  #
  # Check to see if there are more than one page of results ...
  # CloudFlareDNS only gives you a maximum of 100 records per page.
  #
  while count*page_number < total_count
    page_number += 1
    response = cfdns.list_all_dns_records(page_number)
    records += response['result']
  end 
  puts "Total Records: #{total_count} Count: #{count}" if @debug
end 

unless records.nil?
  records.each do |dns_record|
    iter = model.append

    # Add the DNS record data to the model
    iter.set_value(0, dns_record['name'])
    iter.set_value(1, dns_record['content'])
    iter.set_value(2, dns_record['id'])
  end
end	

# Phase 2 functionality ;-)
#button = Gtk::Button.new(:label => "add")
#button.can_focus=true
	
#i = 0
#button.signal_connect("clicked") do
#  iter = model.append
#  iter[0] =  "add item #{i}"
#  i += 1
#end
	
#box2.pack_start(button, false, true, 0)

button = Gtk::Button.new(:label => "Remove DNS Entry")
button.can_focus=true
button.signal_connect("clicked") do
  iter = treeview.selection.selected

  # Now lets call CloudFlareDNS gem to remove the entry.
  dns_record_id = iter.get_value(2)
  puts "Deleting DNS record: #{dns_record_id}" if @debug
  response = cfdns.delete_cloudflare_dns_record ( dns_record_id)
  
  if response['success']
    puts "Deleted record successully #{dns_record_id}" 
    model.remove(iter) if iter
  end

end
box2.pack_start(button, false, true, 0)

separator = Gtk::Separator.new(:horizontal)
box1.pack_start(separator, false, true, 0)
separator.show

box2 = Gtk::Box.new(:vertical, 10)
box2.border_width = 10
box1.pack_start(box2, false, true, 0)

button = Gtk::Button.new(:label => "close")
button.signal_connect("clicked") do
  Gtk.main_quit
end
box2.pack_start(button, true, true, 0)
button.can_default=true
button.grab_default

window.set_default_size(300, 300)
window.show_all

Gtk.main
