import argparse


def parse_args() -> argparse.Namespace:
    """Parse arguments

    Args:

    Returns:
        argparse.Namespace:
    """
    parser = argparse.ArgumentParser(description="")
    parser.add_argument(
        "--long",
        "-l",
        help="",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
