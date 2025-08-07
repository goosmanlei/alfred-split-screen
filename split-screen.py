import os
import subprocess
import json
import sys

log_fp = open('./split-screen.log', 'w', encoding='utf-8')
def log(content):
    log_fp.write(content + '\n')

def simple_command(cmd):
    try:
        output = subprocess.check_output(
            cmd,
            shell = True,
            text = True,
            stderr = subprocess.STDOUT
        )
        return output.strip()
    except subprocess.CalledProcessError as e:
        return ""

# 获取所有环境变量
all_env_vars = os.environ

# 打印所有环境变量
log('all_env_vars:')
for var_name, var_value in all_env_vars.items():
    log(f"{var_name} = {var_value}")

# load all config
config = {}
with open('split-screen.csv', 'r', encoding = 'utf-8') as cfg_fp:
    for line_num, line in enumerate(cfg_fp, 1):
        line = line.strip()
        if not line:
            continue
        elements = line.split()
        if len(elements) != 5:
            log(f'config error: line_num = {line_num}')
            continue
        config[elements[0]] = {
            "x": float(elements[1]),
            "y": float(elements[2]),
            "width": float(elements[3]),
            "height":  float(elements[4]),
        }
config_json = json.dumps(config, indent = 4)
log(f'config_json: {config_json}')

resolution_json = simple_command("displayplacer list | awk -f split-screen.awk")
screen_bounds = json.loads(resolution_json)
log(f'screen_bounds: {screen_bounds}')

current_bounds = json.loads(os.getenv('current_bounds'))

# process height of menubar
height_of_menubar = 25
screen_bounds['main']['y'] += height_of_menubar
screen_bounds['main']['height'] -= height_of_menubar
screen_bounds['dual']['y'] += height_of_menubar
screen_bounds['dual']['height'] -= height_of_menubar
log(f'process height_of_menubar: {height_of_menubar}')
log(f'after menubar process screen_bounds: {screen_bounds}')

input_action_str = os.getenv('input_action')
input_actions = input_action_str.split()
log(f'input_actions: {input_actions}')
which_screen = input_actions[0]
if input_actions[1] in config:
    cfg_key = input_actions[1]
    percentX = config[cfg_key]['x']
    percentY = config[cfg_key]['y']
    percentW = config[cfg_key]['width']
    percentH = config[cfg_key]['height']
else:
    percentX = float(input_actions[1])
    percentY = float(input_actions[2])
    percentW = float(input_actions[3])
    percentH = float(input_actions[4])
# convert unit
if percentX > 1:
    percentX = percentX / 100
if percentY > 1:
    percentY = percentY / 100
if percentW > 1:
    percentW = percentW / 100
if percentH > 1:
    percentH = percentH / 100
log(f'which_screen: {which_screen}, percentX: {percentX}, percentY: {percentY}, percentW: {percentW}, percentH: {percentH}')

target_bounds = screen_bounds[which_screen]
log(f'current_bounds: {current_bounds}')
log(f'percentX: {percentX}, percentY: {percentY}, percentW: {percentW}, percentH: {percentH}')
log(f'target screen_bounds: {target_bounds}')
# calc real value
new_bounds = {}
new_bounds['x'] = int(target_bounds['x'] + target_bounds['width'] * percentX)
new_bounds['y'] = int(target_bounds['y'] + target_bounds['height'] * percentY)
new_bounds['width'] = int(target_bounds['width'] * percentW)
new_bounds['height'] = int(target_bounds['height'] * percentH)
log(f'new_bounds: {new_bounds}')

print(f"{new_bounds['x']} {new_bounds['y']} {new_bounds['width']} {new_bounds['height']}")