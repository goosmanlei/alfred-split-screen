import os
import subprocess
import json
import sys

log_fp = open('./bounds.log', 'w', encoding='utf-8')
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

def log_all_evn():
    # 获取所有环境变量
    all_env_vars = os.environ

    # 打印所有环境变量
    log('all_env_vars:')
    for var_name, var_value in all_env_vars.items():
        log(f"{var_name} = {var_value}")

def load_config():
    config = {}
    with open('bounds.csv', 'r', encoding = 'utf-8') as cfg_fp:
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
    log(f'config: {config}')
    return config

def load_screen_bounds(height_of_menubar = 25):
    resolution_json = simple_command("displayplacer list | awk -f bounds.awk")
    screen_bounds = json.loads(resolution_json)

    screen_bounds['main']['y'] += height_of_menubar
    screen_bounds['main']['height'] -= height_of_menubar
    screen_bounds['dual']['y'] += height_of_menubar
    screen_bounds['dual']['height'] -= height_of_menubar
    log(f'screen_bounds[height_of_menubar = {height_of_menubar}]: {screen_bounds}')

    return screen_bounds

def load_input_actions(config):
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
    return which_screen, percentX, percentY, percentW, percentH

def get_new_bounds(target_bounds, percentX, percentY, percentW, percentH):
    log(f'target_bounds: {target_bounds}')
    log(f'percentX: {percentX}, percentY: {percentY}, percentW: {percentW}, percentH: {percentH}')
    # calc real value
    new_bounds = {}
    new_bounds['x'] = int(target_bounds['x'] + target_bounds['width'] * percentX)
    new_bounds['y'] = int(target_bounds['y'] + target_bounds['height'] * percentY)
    new_bounds['width'] = int(target_bounds['width'] * percentW)
    new_bounds['height'] = int(target_bounds['height'] * percentH)
    log(f'new_bounds: {new_bounds}')
    return new_bounds

