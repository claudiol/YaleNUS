=begin
	  CloudFlareTool.rb - Ruby/GTK Tool for CloudFlareDNS
	
	  Copyright (c) 2002-2006 Ruby-GNOME2 Project Team
	  This program is licenced under the same licence as Ruby-GNOME2.	
=end
	
require 'gtk3'
require 'CloudFlareDNS'

@debug = false

def on_ques (message)
  
  md = Gtk::MessageDialog.new :parent => nil, 
  :flags => :destroy_with_parent, :type => :question, 
  :buttons_type => :yes_no, :message => "#{message}?"
  response = md.run
  md.destroy
  if response == Gtk::ResponseType::YES
    return true
  else
    return false
  end
end

def on_info(message)
 
  md = Gtk::MessageDialog.new :parent => nil, 
  :flags => :destroy_with_parent, :type => :info, 
  :buttons_type => :close, :message => "#{message}"
  md.run
  md.destroy
end

def status_info(message, parent)
 
  md = Gtk::MessageDialog.new :parent => parent, 
  :flags => :destroy_with_parent, :type => :info, 
  :buttons_type => :none, :message => "#{message}"
  return md
end


def on_erro(message)
  
  md = Gtk::MessageDialog.new :parent => nil, 
  :flags => :modal, :type => :error, 
  :buttons_type => :close, :message => "#{message}"
  md.run
  md.destroy
end


def on_warn(message)
  
  md = Gtk::MessageDialog.new :parent => nil, 
  :flags => :destroy_with_parent, :type =>  :warning, 
  :buttons_type => :close, :message => "#{message}"
  md.run
  md.destroy
end

def get_dns_records()
  page_number = 1
  response = @cfdns.list_all_dns_records(page_number)

  unless response.nil?
    if response["success"]
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
        response = @cfdns.list_all_dns_records(page_number)
        records += response['result']
      end 
      puts "Total Records: #{total_count} Count: #{count}" if @debug
    end 
  end
  return records
end

options={}
options[:config_file] = '../test/cloudflare-config.yaml'
	
window = Gtk::Window.new("CloudFlareDNS Tool")
window.realize
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

watch = Gdk::Cursor.new(:watch)
arrow = Gdk::Cursor.new(:arrow)

# Lets use the CloudFlareDNS to get DNS records ...	
@cfdns = CloudFlareDNS.new(options)

window.window.set_cursor(watch)

records = get_dns_records()
unless records.nil?
  records.each do |dns_record|
    iter = model.append

    # Add the DNS record data to the model
    iter.set_value(0, dns_record['name'])
    iter.set_value(1, dns_record['content'])
    iter.set_value(2, dns_record['id'])
  end
else
  on_warn("No records retrieved from CloudFlareDNS service")
end

window.window.set_cursor(arrow)

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

refresh_button = Gtk::Button.new(:label => "Refresh List")
refresh_button.can_focus=true
refresh_button.signal_connect("clicked") do
  records = get_dns_records()
  model.clear
  unless records.nil?
    records.each do |dns_record|
      iter = model.append
  
      # Add the DNS record data to the model
      iter.set_value(0, dns_record['name'])
      iter.set_value(1, dns_record['content'])
      iter.set_value(2, dns_record['id'])
    end
    on_info("All records retrieved from CloudFlareDNS service successfully")
  else
    on_warn("No records retrieved from CloudFlareDNS service")
  end
end
box2.pack_start(refresh_button, false, true, 0)

button = Gtk::Button.new(:label => "Remove DNS Entry")
button.can_focus=true
button.signal_connect("clicked") do
  window.window.set_cursor(watch)
  iter = treeview.selection.selected

  unless iter.nil?
    # Now lets call CloudFlareDNS gem to remove the entry.
    dns_name = iter.get_value(0)
    dns_ip = iter.get_value(1)
    dns_record_id = iter.get_value(2)
    
    if on_ques ( "Are you sure to delete DNS Record [" + dns_name + " " + dns_ip + " " + dns_record_id + "]" )
      puts "Deleting DNS record: #{dns_record_id}" if @debug
      response = @cfdns.delete_cloudflare_dns_record ( dns_record_id)
      
      if response['success']
        model.remove(iter) if iter
        on_info "Deleted record successully #{dns_record_id}" 
      end
    end
  else
    on_warn("No record selected to remove.")
  end
  window.window.set_cursor(arrow)
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

  if on_ques("Are you sure you want to quit")
    Gtk.main_quit
  end
end
box2.pack_start(button, true, true, 0)
button.can_default=true
button.grab_default

window.set_default_size(600, 400)
window.show_all

window.window.set_cursor(arrow)
Gtk.main
