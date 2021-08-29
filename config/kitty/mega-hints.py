# -*- coding: UTF-8 -*-

import re
import os
import subprocess
from os.path import abspath
from pprint import pprint

def shell(command):
    return subprocess.run(command.split(' '), stdout=subprocess.PIPE).stdout.decode('utf-8').rstrip()

def camel_to_snake(string):
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', string)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def mark(text, args, Mark, extra_cli_args, *a):
    # This function is responsible for finding all
    # matching text.
    # We mark all individual word for potential selection

    send_to = 'boss' if len(extra_cli_args) == 0 else extra_cli_args[0]

    path_prefix = os.getcwd()

    if send_to == 'tmux':
        path_prefix = shell('tmux display-message -p -F #{pane_current_path} -t0')

    regexp = re.compile(
        '(?P<rails_log_controller>(?:[A-Z]\\w*::)*[A-Z]\\w*Controller#\\w+)|'
        'Render(?:ed|ing) (?P<rails_log_partial>[-a-zA-Z0-9_+-,./]+)|'
        '(?P<url>(https?|tcp)://[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\b([-a-zA-Z0-9@:%_\\+.~#?&/=]*))|'
        '\\+\\+\\+ b/?(?P<diff_path>([~./]?[-a-zA-Z0-9_+-,./]+(?::\\d+)?))|'
        '(?P<path>([~./]?[-a-zA-Z0-9_+-,./]+(?::\\d+)?))'
        )

    mark_idx = 0
    for _idx, m in enumerate(re.finditer(regexp, text)):
        start, end = m.span()
        mark_text = text[start:end].replace('\n', '').replace('\0', '')

        path_match = m.groupdict()['path']
        diff_path_match = m.groupdict()['diff_path']
        url_match = m.groupdict()['url']
        rails_controller_match = m.groupdict()['rails_log_controller']
        rails_partial_match = m.groupdict()['rails_log_partial']

        mark_data = {}

        if path_match or diff_path_match:
            if diff_path_match:
                start, end = m.span('diff_path')
                mark_text = text[start:end].replace('\n', '').replace('\0', '')

            parts = mark_text.rsplit(':', 1)
            file_path = parts[0]

            if file_path != '.' and file_path != '..' and file_path != '/':
                # file_path = os.path.join(path_prefix, file_path)
                file_path = abspath(os.path.join(path_prefix, os.path.expanduser(file_path)))
                if os.path.isfile(file_path):
                    mark_data = {'file_path': file_path}
                    if len(parts) > 1:
                        mark_data['line_number'] = parts[1]

        elif rails_partial_match:
            start, end = m.span('rails_log_partial')
            mark_text = text[start:end].replace('\n', '').replace('\0', '')
            file_path = os.path.join(path_prefix, 'app/views/' + mark_text)

            if os.path.exists(file_path):
                mark_data = {
                    'file_path': file_path
                    }

        elif url_match:
            mark_data = {
                'url': mark_text.replace('tcp', 'http')
                }

        elif rails_controller_match:
            controller_class, action = mark_text.split('#')
            controller_path = './app/controllers/' + '/'.join(
                map(camel_to_snake, controller_class.split('::'))
                ) + '.rb'
            controller_path = os.path.join(path_prefix, controller_path)

            method_def_regex = re.compile('^\\s*def\\s+%s' % (action))

            if os.path.exists(controller_path):
                mark_data = {'file_path': controller_path}

                with open(controller_path) as ruby_file:
                    line_number = 0
                    for line in ruby_file:
                        line_number += 1

                        if method_def_regex.match(line):
                            mark_data['line_number'] = line_number

        # mark_data will be available in data['groupdicts']
        if mark_data:
            yield Mark(mark_idx, start, end, mark_text, mark_data)
            mark_idx += 1

def handle_result(args, data, target_window_id, boss, extra_cli_args, *a):
    # This function is responsible for performing some
    # action on the selected text.
    # matches is a list of the selected entries and groupdicts contains
    # the arbitrary data associated with each entry in mark() above
    send_to = 'boss' if len(extra_cli_args) == 0 else extra_cli_args[0]

    matches, groupdicts = [], []
    for m, g in zip(data['match'], data['groupdicts']):
        if m:
            matches.append(m), groupdicts.append(g)

    for word, data in zip(matches, groupdicts):
        if 'url' in data:
            boss.open_url(data['url'])

        if 'file_path' in data:
            if send_to == 'tmux':
                window_names = shell('tmux list-windows -F #{window_name}').split('\n')
                vim_window_names = list(filter(lambda x: x == 'vim' or x == 'nvim', window_names))

                if len(vim_window_names):
                    os.system('tmux select-window -t %s' %(vim_window_names[0]))
                    vim_pane_id = shell('tmux list-panes -F "#{pane_id}" -t %s' %(vim_window_names[0])).split('\n')[0]
                    os.system('tmux send-keys -t %s Escape' %(vim_pane_id))

                    if 'line_number' in data:
                        os.system('tmux send-keys -t %s ":e +%s %s" Enter zz' %(vim_pane_id, data['line_number'], data['file_path']))
                    else:
                        os.system('tmux send-keys -t %s ":e %s" Enter zz' %(vim_pane_id, data['file_path']))
                else:
                    raise Exception('Could not find "vim" or "nvim" window in the current session')

            else:
                file_url = data['file_path']

                if 'line_number' in data:
                    file_url += ':%d' %(data['line_number'])

                os.system('%s %s' %(' '.join(extra_cli_args), file_url))

# if __name__ == "__main__":
#     from kittens.tui.loop import debug
#     cwd = os.getcwd()
#     debug({'cwd': cwd})

if __name__ == "change to __main__ when running this directly":

    text = """
Rendered layouts/_base.html.erb (Duration: 32.9ms | Allocations: 2204)
Completed 200 OK in 367ms (Views: 316.5ms | ActiveRecord: 23.2ms | Allocations: 40554)


Started GET "/en/orders/1007056676" for ::1 at 2019-11-18 12:49:58 +0100
Processing by OrdersController#show as HTML
  Parameters: {"locale"=>"en", "id"=>"1007056676"}
  Client Load (1.4ms)  SELECT "clients".* FROM "clients" WHERE "clients"."subdomain" = $1 LIMIT $2  [["subdomain", "zams"], ["LIMIT", 1]]
  ↳ app/controllers/concerns/tenantable.rb:22:in `current_tenant_is_client_with'
  User Load (1.0ms)  SELECT "users".* FROM "users" WHERE "users"."client_id" = $1 AND "users"."id" = $2 LIMIT $3  [["client_id", 898370464], ["id", 599798772], ["LIMIT", 1]]
  ↳ app/controllers/client_base_controller.rb:48:in `current_user'
  Page Load (1.8ms)  SELECT slug, title FROM "pages" WHERE "pages"."client_id" = $1  [["client_id", 898370464]]
  ↳ app/models/page.rb:19:in `all_slugs_and_titles'
  Order Load (0.6ms)  SELECT "orders".* FROM "orders" WHERE "orders"."client_id" = $1 AND "orders"."user_id" = $2 AND "orders"."id" = $3 LIMIT $4  [["client_id", 898370464], ["user_id", 599798772], ["id", 1007056676], ["LIMIT", 1]]
  ↳ app/controllers/orders_controller.rb:5:in `show'
  Rendering orders/show.html.erb within layouts/application
  LineItem Load (2.0ms)  SELECT "line_items".* FROM "line_items" INNER JOIN "line_item_groups" ON "line_items"."line_item_group_id" = "line_item_groups"."id" WHERE "line_items"."client_id" = $1 AND "line_item_groups"."client_id" = $2 AND "line_item_groups"."order_id" = $3  [["client_id", 898370464], ["client_id", 898370464], ["order_id", 1007056676]]
  ↳ app/models/order.rb:30:in `number_of_items'
  LineItemGroup Load (0.4ms)  SELECT "line_item_groups".* FROM "line_item_groups" WHERE "line_item_groups"."client_id" = $1 AND "line_item_groups"."order_id" = $2  [["client_id", 898370464], ["order_id", 1007056676]]
  ↳ app/models/order.rb:38:in `pending_approval?'
  VetPrescription Load (0.3ms)  SELECT "vet_prescriptions".* FROM "vet_prescriptions" WHERE "vet_prescriptions"."client_id" = $1 AND "vet_prescriptions"."id" = $2 LIMIT $3  [["client_id", 898370464], ["id", 1029531331], ["LIMIT", 1]]
  ↳ app/models/line_item_group.rb:21:in `effective_strategy'
  LineItem Load (1.2ms)  SELECT "line_items".* FROM "line_items" WHERE "line_items"."client_id" = $1 AND "line_items"."line_item_group_id" = $2  [["client_id", 898370464], ["line_item_group_id", 1060584122]]
  ↳ app/views/partials/_order_vet_prescription_table.html.erb:11
  Product Load (1.0ms)  SELECT "products".* FROM "products" WHERE "products"."id" = $1 LIMIT $2  [["id", 979904108], ["LIMIT", 1]]
  ↳ app/models/line_item.rb:15:in `image_url'
  Rendered partials/_order_vet_prescription_table.html.erb (Duration: 26.7ms | Allocations: 3815)
  VetPrescriptionDetail Load (1.4ms)  SELECT "vet_prescription_details".* FROM "vet_prescription_details" WHERE "vet_prescription_details"."client_id" = $1 AND "vet_prescription_details"."vet_prescription_id" = $2 LIMIT $3  [["client_id", 898370464], ["vet_prescription_id", 1029531331], ["LIMIT", 1]]
  ↳ app/views/partials/_vet_prescription_summary.html.erb:1
  Rendered partials/_vet_prescription_summary.html.erb (Duration: 18.3ms | Allocations: 2070)
  Rendered orders/_vet_prescription.html.erb (Duration: 50.7ms | Allocations: 7448)
  ShippingAddress Load (0.5ms)  SELECT "addresses".* FROM "addresses" WHERE "addresses"."client_id" = $1 AND "addresses"."type" = $2 AND "addresses"."id" = $3 LIMIT $4  [["client_id", 898370464], ["type", "ShippingAddress"], ["id", 959340445], ["LIMIT", 1]]
  ↳ app/views/orders/_order_details.html.erb:25
  Dispatch Exists? (0.8ms)  SELECT 1 AS one FROM "dispatches" INNER JOIN "line_item_groups" ON "dispatches"."line_item_group_id" = "line_item_groups"."id" WHERE "dispatches"."client_id" = $1 AND "line_item_groups"."client_id" = $2 AND "line_item_groups"."order_id" = $3 LIMIT $4  [["client_id", 898370464], ["client_id", 898370464], ["order_id", 1007056676], ["LIMIT", 1]]
  ↳ app/views/orders/_order_details.html.erb:33
  Dispatch Load (0.7ms)  SELECT "dispatches".* FROM "dispatches" INNER JOIN "line_item_groups" ON "dispatches"."line_item_group_id" = "line_item_groups"."id" WHERE "dispatches"."client_id" = $1 AND "line_item_groups"."client_id" = $2 AND "line_item_groups"."order_id" = $3  [["client_id", 898370464], ["client_id", 898370464], ["order_id", 1007056676]]
  ↳ app/views/orders/_order_details.html.erb:34:in `sort'
  DispatchStatusUpdate Load (0.6ms)  SELECT "dispatch_status_updates".* FROM "dispatch_status_updates" WHERE "dispatch_status_updates"."client_id" = $1 AND "dispatch_status_updates"."dispatch_id" = $2 ORDER BY id  [["client_id", 898370464], ["dispatch_id", 305891094]]
  ↳ app/views/orders/_order_details.html.erb:44
  Payment Load (0.5ms)  SELECT "payments".* FROM "payments" WHERE "payments"."client_id" = $1 AND "payments"."order_id" = $2  [["client_id", 898370464], ["order_id", 1007056676]]
  ↳ app/views/orders/_order_details.html.erb:63
  Card Load (1.9ms)  SELECT "cards".* FROM "cards" WHERE "cards"."client_id" = $1 AND "cards"."id" = $2 LIMIT $3  [["client_id", 898370464], ["id", 1037122605], ["LIMIT", 1]]
  ↳ app/views/orders/_order_details.html.erb:77
  Rendered orders/_order_details.html.erb (Duration: 111.7ms | Allocations: 22207)
  Rendered orders/show.html.erb within layouts/application (Duration: 151.2ms | Allocations: 27021)
  ClientConfig Load (0.6ms)  SELECT "client_configs".* FROM "client_configs" WHERE "client_configs"."client_id" = $1 ORDER BY "client_configs"."id" DESC LIMIT $2  [["client_id", 898370464], ["LIMIT", 1]]
  ↳ app/models/client_config.rb:53:in `entity'
  Basket Load (0.4ms)  SELECT "baskets".* FROM "baskets" WHERE "baskets"."client_id" = $1 AND "baskets"."user_id" = $2 LIMIT $3  [["client_id", 898370464], ["user_id", 599798772], ["LIMIT", 1]]
  ↳ app/controllers/concerns/basketable.rb:14:in `current_basket'
  CACHE ClientConfig Load (0.1ms)  SELECT "client_configs".* FROM "client_configs" WHERE "client_configs"."client_id" = $1 ORDER BY "client_configs"."id" DESC LIMIT $2  [["client_id", 898370464], ["LIMIT", 1]]
  ↳ app/models/client_config.rb:53:in `entity'
  Rendered partials/_client_user_bar.html.erb (Duration: 22.6ms | Allocations: 5429)
  ActiveStorage::Attachment Load (0.3ms)  SELECT "active_storage_attachments".* FROM "active_storage_attachments" WHERE "active_storage_attachments"."record_id" = $1 AND "active_storage_attachments"."record_type" = $2 AND "active_storage_attachments"."name" = $3 LIMIT $4  [["record_id", 906572757], ["record_type", "ClientConfig"], ["name", "logo_image"], ["LIMIT", 1]]
  ↳ app/views/partials/_client_logo.html.erb:2
  Rendered partials/_client_logo.html.erb (Duration: 7.5ms | Allocations: 1672)
  Rendered partials/_client_logo_bar.html.erb (Duration: 10.3ms | Allocations: 2232)
  Rendered partials/_flash.html.erb (Duration: 2.9ms | Allocations: 186)
  Rendered partials/_current_theme.html.erb (Duration: 1.5ms | Allocations: 587)
  Rendered layouts/_base.html.erb (Duration: 40.7ms | Allocations: 3116)
Completed 200 OK in 307ms (Views: 256.6ms | ActiveRecord: 17.5ms | Allocations: 47708)

    """

    def ap(idx, start, end, mark_text, groupdicts):
        pprint({
            'idx': idx,
            'start': start,
            'end': end,
            'mark_text': mark_text,
            'groupdicts': groupdicts
            })

    marks = mark(text, None, ap, [])
    for mark in marks:
        print('new mark')
