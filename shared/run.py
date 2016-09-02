from time import sleep

with open('test.log', 'w') as f:
    while True:
        f.write('test1\n')
        print('mehe')
        f.flush()
        sleep(1)
