import urllib.request
import json

base_url = 'http://94.136.185.87:16000'

# Login
req = urllib.request.Request(
    f'{base_url}/auth/login',
    data=json.dumps({'email': 'mobile_onshore', 'password': 'password'}).encode('utf-8'),
    headers={'Content-Type': 'application/json'}
)
with urllib.request.urlopen(req) as resp:
    login_data = json.loads(resp.read().decode('utf-8'))

token = login_data['accessToken']
user_id = login_data['user']['_id']
print(f"Logged in user_id: {user_id}")

headers = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

def test_endpoint(ep):
    print(f"\n=== Testing {ep} ===")
    try:
        r = urllib.request.Request(f'{base_url}{ep}', headers=headers)
        with urllib.request.urlopen(r) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            print("Status: 200, Keys:", list(data.keys()) if isinstance(data, dict) else type(data))
            if isinstance(data, dict):
                inner = data.get('data') or data.get('result') or data.get('work_order') or data.get('workOrder')
                if isinstance(inner, list):
                    print(f"Items count: {len(inner)}")
                    for idx, item in enumerate(inner):
                        if isinstance(item, dict):
                            print(f"  Item {idx}: woNumber={item.get('woNumber')}, id={item.get('_id')}, assignedTo={item.get('assignedTo')}, assigendTeam={item.get('assigendTeam')}, assets_count={len(item.get('assets', []))}")
                elif isinstance(inner, dict):
                    print(f"Inner is dict with keys: {list(inner.keys())}")
            return data
    except Exception as e:
        print(f"Error: {e}")

test_endpoint(f'/onshore/user-work-orders/{user_id}')
test_endpoint('/onshore/user-work-orders')
test_endpoint('/onshore/workorder/assets')
test_endpoint('/onshore/work-order')
