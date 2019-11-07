import string
import secrets

size = 32
chars = string.ascii_uppercase + string.ascii_lowercase + string.digits
# chars += '%&$#()'

print(''.join(secrets.choice(chars) for x in range(size)))
