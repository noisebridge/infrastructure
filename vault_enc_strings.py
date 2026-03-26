import sys
import yaml
import argparse
from ansible.parsing.vault import VaultLib
from ansible.cli import CLI
from ansible import constants as C
from ansible.parsing.dataloader import DataLoader
from ansible.parsing.yaml.dumper import AnsibleDumper
from ansible.parsing.yaml.loader import AnsibleLoader
from ansible.parsing.yaml.objects import AnsibleVaultEncryptedUnicode


class VaultHelper():
    def __init__(self, vault_id):
        loader = DataLoader()
        vaults = [v for v in C.DEFAULT_VAULT_IDENTITY_LIST if v.startswith('{0}@'.format(vault_id))]
        if len(vaults) != 1:
            raise ValueError("'{0}' does not exist in ansible.cfg '{1}'".format(vault_id, C.DEFAULT_VAULT_IDENTITY_LIST))

        self.vault_id = vault_id
        vault_secret = CLI.setup_vault_secrets(loader=loader, vault_ids=vaults)
        self.vault = VaultLib(vault_secret)

    def convert_vault_to_strings(self, vault_data):
        if not is_vault_encrypted(vault_data):
            # Already plaintext YAML — just parse and re-encrypt string values
            d = yaml.load(vault_data, Loader=AnsibleLoader)
            self._encrypt_dict(d)
            return d

        decrypted = self.vault.decrypt(vault_data)
        d = yaml.load(decrypted, Loader=AnsibleLoader)
        self._encrypt_dict(d)
        return d

    def _encrypt_dict(self, d):
        for key in d:
            value = d[key]
            if isinstance(value, str):
                d[key] = AnsibleVaultEncryptedUnicode(
                    self.vault.encrypt(plaintext=value, vault_id=self.vault_id))
            elif isinstance(value, list):
                for item in value:
                    self._encrypt_dict(item)
            elif isinstance(value, dict):
                self._encrypt_dict(value)

def is_vault_encrypted(raw: str) -> bool:
    return raw.lstrip().startswith('$ANSIBLE_VAULT')

def has_inline_vault_values(raw: str) -> bool:
    return '!vault' in raw

def main():
    parser = argparse.ArgumentParser(
        description="Re-encrypts a vault file with per-string encryption.",
        epilog=(
            "ansible.cfg must have vault_identity_list configured:\n"
            "  [defaults]\n"
            "  vault_identity_list = prod@.vault_pass.prod, dev@/home/user/.vault_pass.dev\n\n"
            "The --vault-id value must match one of those identity names (e.g. 'prod')."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument('--input-file', '-i', help='File to read from', required=True)
    parser.add_argument('--output-file', '-o', help='File to write to (default: stdout)')
    parser.add_argument('-O', '--overwrite', action='store_true',
                        help='Overwrite input file in place')
    parser.add_argument('--vault-id', help='Vault id used for the encryption', required=True)
    parser.add_argument('-d', '--decrypt', action='store_true',
                        help='Print decrypted plaintext to stdout (does not write to file)')
    args = parser.parse_args()

    if args.overwrite and args.output_file:
        parser.error('-O/--overwrite and --output-file are mutually exclusive')
    if args.decrypt and (args.overwrite or args.output_file):
        parser.error('-d/--decrypt is view-only and cannot be combined with -O or --output-file')

    original_secrets = open(args.input_file).read()
    vault = VaultHelper(args.vault_id)
    converted_secrets = vault.convert_vault_to_strings(original_secrets)


    if has_inline_vault_values(original_secrets):
        parser.error(
            f"{args.input_file} contains inline !vault encrypted values, which is not supported.\n"
            "Convert to a whole-file vault first with: ansible-vault encrypt <file>"
        )

    if args.decrypt:
        if not is_vault_encrypted(original_secrets):
            sys.stdout.write(original_secrets)  # already plaintext, just echo it
            return
        decrypted = vault.vault.decrypt(original_secrets)
        sys.stdout.write(decrypted.decode() if isinstance(decrypted, bytes) else decrypted)
        return

    if args.overwrite:
        output_path = args.input_file
    else:
        output_path = args.output_file  # may be None

    if output_path:
        with open(output_path, 'w+') as f:
            yaml.dump(converted_secrets, Dumper=AnsibleDumper, stream=f, explicit_start=True)
    else:
        yaml.dump(converted_secrets, Dumper=AnsibleDumper, stream=sys.stdout, explicit_start=True)

if __name__ == "__main__":
    main()
