DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/../test-bootstrap.bash"

function test_should_halt {
    cat "$DIR/share/ec2-describe-instances.json" | jp -p
      ok $(( $? == 0 )) "got here"
}

test_should_halt
end
